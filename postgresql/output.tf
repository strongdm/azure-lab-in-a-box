output "fqdn" {
    value = azurerm_postgresql_server.server.fqdn
}

output "thistagset" {
    value = local.thistagset
}
