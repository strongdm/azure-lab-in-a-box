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

resource "tls_private_key" "vault" {
    algorithm = "RSA"
    rsa_bits  = 2048
}

resource "azurerm_role_assignment" "hcvault" {
  principal_id   = azurerm_linux_virtual_machine.vault.identity[0].principal_id
  role_definition_name = "Key Vault Crypto User"  # This allows the Managed Identity to read secrets
  scope           = var.akvid
}

data "azurerm_subscription" "this" {}

data "azurerm_resource_group" "this" {
  name = var.rg
}

data "azurerm_client_config" "this" {}

resource "azurerm_role_assignment" "azureauth" {
  principal_id   = azurerm_linux_virtual_machine.vault.identity[0].principal_id
  scope          = data.azurerm_resource_group.this.id
  role_definition_name = "Reader"  # Built-in Read-only role
  #scope           = "${data.azurerm_subscription.this.name}/resourceGroups/${var.rg}"
}

resource "azurerm_key_vault_key" "hcvault" {
  name         = "${var.name}-hcvault-sealkey"
  key_vault_id = var.akvid
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

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