#--------------------------------------------------------------
# Azure Blob Storage Read-Only Module Outputs
#
# This file defines the output values from the Blob Storage read-only module
# that other modules and resources need to reference for StrongDM integration.
#--------------------------------------------------------------

output "app_id" {
  description = "Azure AD application (client) ID"
  value       = azuread_application.blobro.client_id
}

output "password" {
  description = "Service principal password"
  value       = azuread_service_principal_password.blobro.value
  sensitive   = true
}

output "storage_account_name" {
  description = "Name of the created storage account"
  value       = azurerm_storage_account.blobro.name
}

output "storage_account_id" {
  description = "ID of the created storage account"
  value       = azurerm_storage_account.blobro.id
}

output "container_name" {
  description = "Name of the sample container"
  value       = azurerm_storage_container.sample.name
}

output "tags" {
  description = "Tags applied to resources"
  value       = local.thistagset
}
