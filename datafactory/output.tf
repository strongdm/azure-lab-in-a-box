#--------------------------------------------------------------
# Azure Data Factory Module Outputs
#
# This file defines the output values from the Data Factory module
# that other modules and resources need to reference for StrongDM integration.
#--------------------------------------------------------------

output "app_id" {
  description = "Azure AD application (client) ID"
  value       = azuread_application.datafactory.client_id
}

output "password" {
  description = "Service principal password"
  value       = azuread_service_principal_password.datafactory.value
  sensitive   = true
}

output "data_factory_name" {
  description = "Name of the created Data Factory"
  value       = azurerm_data_factory.sample.name
}

output "data_factory_id" {
  description = "ID of the created Data Factory"
  value       = azurerm_data_factory.sample.id
}

output "tags" {
  description = "Tags applied to resources"
  value       = local.thistagset
}
