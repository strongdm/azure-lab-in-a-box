/*
 * Linux Target Implementation
 * Creates an Ubuntu Linux VM that's configured with the StrongDM SSH CA public key
 * Enables secure certificate-based authentication for SSH access
 */

// Network interface for the Linux target VM in the private subnet
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

// Generate SSH key pair for Linux target VM
// Note: This key is separate from StrongDM CA and is used only for initial provisioning
resource "tls_private_key" "linux-target" {
    algorithm = "RSA"
    rsa_bits  = 2048
}

// Linux VM with StrongDM SSH CA configuration
resource "azurerm_linux_virtual_machine" "sshcatarget" {
  name                  = "${var.name}-ssh-ca-target"
  resource_group_name   = var.rg
  location              = var.region
  size                  = "Standard_B1s"  # Minimal VM size
  network_interface_ids = [azurerm_network_interface.sdm-sshca-nic.id]
  
  // Custom data script that installs the StrongDM SSH CA public key
  // This enables certificate-based authentication for StrongDM clients
  user_data             = base64encode(templatefile("${path.module}/ca-provision.tpl", {
    sshca               = var.sshca
    target_user         = var.target_user
    }
   )
  )
  
  // Standard SSH key-based authentication for initial access
  admin_username        = "${var.target_user}"
  // Azure requires an SSH key for Linux VMs
  admin_ssh_key {
    username   = "${var.target_user}"
    public_key = tls_private_key.linux-target.public_key_openssh
  }
  
  // Standard OS disk configuration
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  
  // Ubuntu 20.04 LTS image
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  // Custom VM Tags
  tags = local.thistagset
}