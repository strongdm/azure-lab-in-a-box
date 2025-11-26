#--------------------------------------------------------------
# Azure Blob Storage Full Access Module
#
# This module creates a service principal with full access to Azure Blob
# Storage. This is the Azure equivalent of AWS S3 full access.
#
# The module creates:
# - An Azure AD application
# - A service principal for the application
# - A rotating password for the service principal
# - Role assignment for Storage Blob Data Contributor (full access)
# - A storage account with a sample container for demonstration
#--------------------------------------------------------------

data "azuread_client_config" "current" {}

# Create an Azure AD application for Blob Storage full access
resource "azuread_application" "blobfull" {
  display_name = "${var.name}-SDM-BlobStorage-Full"
  owners       = [data.azuread_client_config.current.object_id]

  feature_tags {
    enterprise            = false
    gallery               = false
    custom_single_sign_on = false
    hide                  = false
  }
}

# Create the service principal
resource "azuread_service_principal" "blobfull" {
  client_id                    = azuread_application.blobfull.client_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]

  feature_tags {
    enterprise            = false
    gallery               = false
    custom_single_sign_on = false
    hide                  = false
  }
}

# Rotate password every 10 days for security
resource "time_rotating" "blobfull" {
  rotation_days = 10
}

# Create a password for the service principal
resource "azuread_service_principal_password" "blobfull" {
  service_principal_id = azuread_service_principal.blobfull.id
  rotate_when_changed = {
    rotation = time_rotating.blobfull.id
  }
}

# Generate a unique name for the storage account
resource "random_pet" "storage_account" {
  prefix    = var.name
  separator = ""
  length    = 1
}

# Create a storage account for demonstration
resource "azurerm_storage_account" "blobfull" {
  name                     = substr(replace("${random_pet.storage_account.id}full", "-", ""), 0, 24)
  resource_group_name      = var.rg
  location                 = data.azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = local.thistagset
}

# Get the resource group details
data "azurerm_resource_group" "rg" {
  name = var.rg
}

# Create a sample container in the storage account
resource "azurerm_storage_container" "sample" {
  name                  = "sample-container"
  storage_account_name  = azurerm_storage_account.blobfull.name
  container_access_type = "private"
}

# Upload a sample blob for demonstration
resource "azurerm_storage_blob" "sample" {
  name                   = "sample-data.txt"
  storage_account_name   = azurerm_storage_account.blobfull.name
  storage_container_name = azurerm_storage_container.sample.name
  type                   = "Block"
  source_content         = "This is sample data for StrongDM Blob Storage full access demonstration."
}

# Assign Storage Blob Data Contributor role to the service principal (full access)
resource "azurerm_role_assignment" "blobfull" {
  principal_id         = azuread_service_principal.blobfull.object_id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = azurerm_storage_account.blobfull.id
}
