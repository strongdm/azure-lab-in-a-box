output "fqdn" {
    value = azurerm_postgresql_flexible_server.server.fqdn
}

output "thistagset" {
    value = local.thistagset
}
