/*
 * Azure Data Factory Target Configuration
 * Creates an Azure service principal with Data Factory Contributor role
 * and registers it as a resource in StrongDM for Azure CLI access.
 * This is the Azure equivalent of AWS Glue full access.
 */

// Create Data Factory access if the create_datafactory flag is set to true
module "datafactory" {
  source = "../datafactory"
  count  = var.create_datafactory == true ? 1 : 0

  name         = var.name
  region       = var.region
  tagset       = var.tagset
  rg           = coalesce(var.rg, one(module.rg[*].rgname))
  subscription = data.azurerm_subscription.subscription.id
}

// Register the Data Factory service principal in StrongDM
// This allows users to access Azure Data Factory via Azure CLI with full permissions
resource "sdm_resource" "datafactory" {
  count = var.create_datafactory == true ? 1 : 0
  azure {
    name      = "${var.name}-datafactory-full"
    app_id    = one(module.datafactory[*].app_id)
    tags      = one(module.datafactory[*].tags)
    password  = one(module.datafactory[*].password)
    tenant_id = data.azurerm_client_config.current.tenant_id
  }
}
