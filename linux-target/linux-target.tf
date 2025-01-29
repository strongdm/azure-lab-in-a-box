resource "azurerm_network_interface" "sdm-sshca-nic" {
  name                = "${var.name}-sshca-nic"
  location            = var.region
  resource_group_name = var.rg

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet
    private_ip_address_allocation = "Dynamic"
  }
}

resource "tls_private_key" "linux-target" {
    algorithm = "RSA"
    rsa_bits  = 2048
}

resource "azurerm_linux_virtual_machine" "sshcatarget" {
  name                  = "${var.name}-ssh-ca-target"
  resource_group_name   = var.rg
  location              = var.region
  size                  = "Standard_B1s"  # Minimal VM size
  network_interface_ids = [azurerm_network_interface.sdm-sshca-nic.id]
  user_data             = base64encode(templatefile("${path.module}/ca-provision.tpl", {
    sshca               = var.sshca
    target_user         = var.target_user
    }
   )
  )
  # Use SSH Key-based Authentication (recommended for security)
  admin_username        = "${var.target_user}"
#Azure doesn't like when we create a server without keys :)
  admin_ssh_key {
    username   = "${var.target_user}"
    public_key = tls_private_key.linux-target.public_key_openssh
  }
  # Define the OS image (Ubuntu 20.04 LTS in this example)
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  # Custom VM Tags
  tags = local.thistagset

}