#--------------------------------------------------------------
# Azure Blob Storage Full Access Module Outputs
#
# This file defines the output values from the Blob Storage full access module
# that other modules and resources need to reference for StrongDM integration.
#--------------------------------------------------------------

output "app_id" {
  description = "Azure AD application (client) ID"
  value       = azuread_application.blobfull.client_id
}

output "password" {
  description = "Service principal password"
  value       = azuread_service_principal_password.blobfull.value
  sensitive   = true
}

output "storage_account_name" {
  description = "Name of the created storage account"
  value       = azurerm_storage_account.blobfull.name
}

output "storage_account_id" {
  description = "ID of the created storage account"
  value       = azurerm_storage_account.blobfull.id
}

output "container_name" {
  description = "Name of the sample container"
  value       = azurerm_storage_container.sample.name
}

output "tags" {
  description = "Tags applied to resources"
  value       = local.thistagset
}
