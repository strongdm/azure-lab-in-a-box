output "app_id" {
  value = azuread_application.sdm.client_id
}

output "password" {
  value = azuread_service_principal_password.sdm.value
}

output "tags" {
  value = local.thistagset
}