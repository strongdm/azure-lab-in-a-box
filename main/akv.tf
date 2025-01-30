resource "random_pet" "akv" {
    prefix = var.name
}
resource "azurerm_key_vault" "sdm" {
  name                        = "${substr(random_pet.akv.id,0,23)}3"  # Must be globally unique
  location                    = var.region
  resource_group_name         = coalesce(var.rg,module.rg[0].rgname)
  enabled_for_disk_encryption = true
  soft_delete_retention_days  = 7
  
  sku_name  = "standard"
  tenant_id = data.azurerm_client_config.current.tenant_id
  
  enable_rbac_authorization = true
}

resource "azurerm_role_assignment" "sdmrelay" {
  principal_id   = azurerm_linux_virtual_machine.sdmrelay.identity[0].principal_id
  role_definition_name = "Key Vault Secrets User"  # This allows the Managed Identity to read secrets
  scope           = azurerm_key_vault.sdm.id
}

resource "azurerm_role_assignment" "currentuser" {
  principal_id   = data.azurerm_client_config.current.object_id
  role_definition_name = "Key Vault Administrator"  # This allows the Managed Identity to read secrets
  scope           = azurerm_key_vault.sdm.id
}

resource "sdm_secret_store" "akv" {
    azure_store {
        name = "Azure Key Vault ${var.name}"
        tags = var.tagset
        vault_uri = azurerm_key_vault.sdm.vault_uri
    }
}