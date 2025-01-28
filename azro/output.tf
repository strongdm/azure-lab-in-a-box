output "app_id" {
    value = azuread_application.sdm.client_id
}

#output "certificate" {
#    value = <<-EOT
#    ${tls_self_signed_cert.sdm.cert_pem}
#    ${tls_private_key.sdm.private_key_pem}
#    EOT
#}

output "password" {
    value = azuread_service_principal_password.sdm.value
}

output "tags" {
    value = local.thistagset
}