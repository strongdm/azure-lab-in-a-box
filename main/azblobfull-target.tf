/*
 * Azure Blob Storage Full Access Target Configuration
 * Creates an Azure service principal with Storage Blob Data Contributor role
 * and registers it as a resource in StrongDM for Azure CLI access.
 * This is the Azure equivalent of AWS S3 full access.
 */

// Create Blob Storage full access if the create_blob_full flag is set to true
module "blobfull" {
  source = "../azblobfull"
  count  = var.create_blob_full == true ? 1 : 0

  name         = var.name
  tagset       = var.tagset
  rg           = coalesce(var.rg, one(module.rg[*].rgname))
  subscription = data.azurerm_subscription.subscription.id
}

// Register the Blob Storage full access service principal in StrongDM
// This allows users to access Azure Blob Storage via Azure CLI with full permissions
resource "sdm_resource" "blobfull" {
  count = var.create_blob_full == true ? 1 : 0
  azure {
    name      = "${var.name}-blob-storage-full"
    app_id    = one(module.blobfull[*].app_id)
    tags      = one(module.blobfull[*].tags)
    password  = one(module.blobfull[*].password)
    tenant_id = data.azurerm_client_config.current.tenant_id
  }
}
