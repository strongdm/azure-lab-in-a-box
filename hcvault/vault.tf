/*
 * HashiCorp Vault Module
 * Creates a single-node HashiCorp Vault instance with Azure Key Vault integration
 * Configured with auto-unseal using Azure Key Vault cryptographic keys
 * Uses managed identity for authentication to Azure services
 */

// Network interface for the HashiCorp Vault VM in the private subnet
resource "azurerm_network_interface" "sdm-vault-nic" {
  name                = "${var.name}-vault-nic"
  location            = var.region
  resource_group_name = var.rg

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet
    private_ip_address_allocation = "Dynamic"
  }
}

// Generate SSH key pair for Vault VM access
resource "tls_private_key" "vault" {
    algorithm = "RSA"
    rsa_bits  = 2048
}

// Grant the Vault VM's managed identity "Key Vault Crypto User" role
// Allows Vault to use Azure Key Vault for auto-unseal operations
resource "azurerm_role_assignment" "hcvault" {
  principal_id   = azurerm_linux_virtual_machine.vault.identity[0].principal_id
  role_definition_name = "Key Vault Crypto User"  // This allows the Managed Identity to read secrets
  scope           = var.akvid
}

// Data sources for current Azure subscription and client configuration
data "azurerm_subscription" "this" {}

data "azurerm_client_config" "this" {}

// Grant the Vault VM's managed identity "Reader" role on the resource group
// Allows Vault to authenticate with Azure and access resources
resource "azurerm_role_assignment" "azureauth" {
  principal_id   = azurerm_linux_virtual_machine.vault.identity[0].principal_id
  scope          = var.rgid
  role_definition_name = "Reader"  // Built-in Read-only role
}

// Create an encryption key in Azure Key Vault for Vault auto-unseal
resource "azurerm_key_vault_key" "hcvault" {
  name         = "${var.name}-hcvault-sealkey"
  key_vault_id = var.akvid
  key_type     = "RSA"
  key_size     = 2048

  // Key operations allowed for this key
  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  // Key rotation policy
  rotation_policy {
    automatic {
      time_before_expiry = "P30D"
    }

    expire_after         = "P90D"
    notify_before_expiry = "P29D"
  }
  tags = local.thistagset

}

resource "azurerm_linux_virtual_machine" "vault" {
  name                  = "${var.name}-hcvault"
  resource_group_name   = var.rg
  location              = var.region
  size                  = "Standard_B1s"  # Minimal VM size
  network_interface_ids = [azurerm_network_interface.sdm-vault-nic.id]
  user_data             = base64encode(templatefile("${path.module}/vault-provision.tpl", {
    sshca               = var.sshca
    target_user         = var.target_user
    vault_version       = var.vault_version
    akvname             = var.akvdns
    akvkey              = azurerm_key_vault_key.hcvault.name
    ip                  = azurerm_network_interface.sdm-vault-nic.private_ip_address
    tenant              = data.azurerm_client_config.this.tenant_id
    }
   )
  )
  # Use SSH Key-based Authentication (recommended for security)
  admin_username        = "${var.target_user}"
#Azure doesn't like when we create a server without keys :)
  admin_ssh_key {
    username   = "${var.target_user}"
    public_key = tls_private_key.vault.public_key_openssh
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
  identity {
    type = "SystemAssigned"
  }

  # Custom VM Tags
  tags = local.thistagset

}