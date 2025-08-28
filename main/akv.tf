/*
 * Azure Key Vault Configuration
 * Sets up a Key Vault to securely store credentials and certificates for the lab environment
 * Configured with RBAC for access control and integrated with StrongDM as a secret store
 */

// Generate a unique name for the Azure Key Vault
resource "random_pet" "akv" {
  prefix = var.name
}

// Create Azure Key Vault with RBAC authorization
resource "azurerm_key_vault" "sdm" {
  name                        = "${substr(random_pet.akv.id, 0, 23)}3" # Must be globally unique
  location                    = var.region
  resource_group_name         = coalesce(var.rg, module.rg[0].rgname)
  enabled_for_disk_encryption = true
  soft_delete_retention_days  = 7

  sku_name  = "standard"
  tenant_id = data.azurerm_client_config.current.tenant_id

  // Use RBAC for access control instead of vault policies
  enable_rbac_authorization = true
}

// Grant the StrongDM relay's managed identity access to read secrets
resource "azurerm_role_assignment" "sdmrelay" {
  principal_id         = azurerm_linux_virtual_machine.sdmrelay.identity[0].principal_id
  role_definition_name = "Key Vault Secrets Officer" # This allows the Managed Identity to read/write secrets
  scope                = azurerm_key_vault.sdm.id
}

// Grant the current user full administrative access to the Key Vault
resource "azurerm_role_assignment" "currentuser" {
  principal_id         = data.azurerm_client_config.current.object_id
  role_definition_name = "Key Vault Administrator"
  scope                = azurerm_key_vault.sdm.id
}

// Register the Azure Key Vault as a secret store in StrongDM
// This allows StrongDM to retrieve credentials from Key Vault when needed
resource "sdm_secret_store" "akv" {
  azure_store {
    name      = "Azure Key Vault ${var.name}"
    tags      = var.tagset
    vault_uri = azurerm_key_vault.sdm.vault_uri
  }
}
