resource "azurerm_network_interface" "sdm-dc-nic" {
  name                = "${var.name}-dc-nic"
  location            = var.region
  resource_group_name = var.rg

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet
    private_ip_address_allocation = "Dynamic"
  }
}


resource "azurerm_windows_virtual_machine" "windowsdc" {
  name                = "${var.name}-dc1"
  computer_name       = "${substr(var.name, 0, 12)}-dc"
  resource_group_name = var.rg
  location            = var.region
  size                = "Standard_DS1_v2"
  admin_username      = var.target_user
  admin_password      = local.admin_password
  network_interface_ids = [
    azurerm_network_interface.sdm-dc-nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  custom_data = base64encode(templatefile("${path.module}/install-dc.ps1.tpl", {
    name     = var.name
    password = local.admin_password
    rdpca    = var.rdpca
    
    target_user  = var.target_user
    domain_users = var.domain_users

    } ))
  tags = local.thistagset

}

resource "azurerm_virtual_machine_extension" "dc1-vm-extension" {
  depends_on=[azurerm_windows_virtual_machine.windowsdc]

  name                 = "${var.name}-dc1-prov"
  virtual_machine_id   = azurerm_windows_virtual_machine.windowsdc.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"
  settings = <<SETTINGS
  {
    "commandToExecute": "copy c:\\AzureData\\CustomData.bin c:\\CustomData.ps1 && powershell -ExecutionPolicy Unrestricted -File c:\\CustomData.ps1"
  }

  SETTINGS

  tags = var.tagset
}