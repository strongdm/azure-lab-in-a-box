/*
 * Windows Target Module
 * Creates a Windows Server VM that joins an existing Active Directory domain
 * Uses StrongDM RDP CA certificate for secure authentication
 */

// Network interface for the Windows Server VM in the private subnet
resource "azurerm_network_interface" "sdm-windows-nic" {
  name                = "${var.name}-windows-nic"
  location            = var.region
  resource_group_name = var.rg

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet
    private_ip_address_allocation = "Dynamic"
  }
}

// Windows Server VM that will be joined to the domain
resource "azurerm_windows_virtual_machine" "windows" {
  name          = "${var.name}-windows-server"
  computer_name = "${substr(var.name, 0, 6)}-server1"

  resource_group_name = var.rg
  location            = var.region
  size                = var.vm_size
  admin_username      = var.target_user
  admin_password      = local.admin_password
  network_interface_ids = [
    azurerm_network_interface.sdm-windows-nic.id,
  ]

  // Standard OS disk configuration
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  // Windows Server 2019 image
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  // Custom script to join the Windows server to the domain
  // Configures DNS settings and runs domain join process
  custom_data = base64encode(templatefile("${path.module}/join-domain.ps1.tpl", {
    domain_name     = var.domain_name
    domain_password = var.domain_password
    domain_admin    = var.domain_admin
    dns             = var.dns
  }))
  tags = local.thistagset
}

// VM extension to execute the domain join script
// This is needed because custom_data doesn't always execute reliably for complex operations
resource "azurerm_virtual_machine_extension" "windows" {
  depends_on = [azurerm_windows_virtual_machine.windows]

  name                 = "${var.name}-server1"
  virtual_machine_id   = azurerm_windows_virtual_machine.windows.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"
  settings             = <<SETTINGS
  {
    "commandToExecute": "copy c:\\AzureData\\CustomData.bin c:\\CustomData.ps1 && powershell -ExecutionPolicy Unrestricted -File c:\\CustomData.ps1"
 
 }

  SETTINGS

  tags = local.thistagset
}