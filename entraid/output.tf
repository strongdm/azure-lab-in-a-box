output "app_id" {
  description = "Application (client) ID for the Entra ID app"
  value       = azuread_application.entraid.client_id
}

output "password" {
  description = "Service principal password/secret"
  value       = azuread_service_principal_password.entraid.value
  sensitive   = true
}

output "object_id" {
  description = "Service principal object ID"
  value       = azuread_service_principal.entraid.object_id
}

output "tags" {
  description = "Tags applied to the StrongDM resource"
  value       = local.thistagset
}
