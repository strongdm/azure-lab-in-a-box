/*
 * Azure Blob Storage Read-Only Target Configuration
 * Creates an Azure service principal with Storage Blob Data Reader role
 * and registers it as a resource in StrongDM for Azure CLI access.
 * This is the Azure equivalent of AWS S3 read-only access.
 */

// Create Blob Storage read-only access if the create_blob_ro flag is set to true
module "blobro" {
  source = "../azblobro"
  count  = var.create_blob_ro == true ? 1 : 0

  name         = var.name
  tagset       = var.tagset
  rg           = coalesce(var.rg, one(module.rg[*].rgname))
  subscription = data.azurerm_subscription.subscription.id
}

// Register the Blob Storage read-only service principal in StrongDM
// This allows users to access Azure Blob Storage via Azure CLI with read-only permissions
resource "sdm_resource" "blobro" {
  count = var.create_blob_ro == true ? 1 : 0
  azure {
    name      = "${var.name}-blob-storage-readonly"
    app_id    = one(module.blobro[*].app_id)
    tags      = one(module.blobro[*].tags)
    password  = one(module.blobro[*].password)
    tenant_id = data.azurerm_client_config.current.tenant_id
  }
}
