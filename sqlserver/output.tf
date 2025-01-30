output "fqdn" {
    value = azurerm_mssql_server.server.fully_qualified_domain_name
}

output "thistagset" {
    value = local.thistagset
}

output "dbname" {
    value = var.dbname
}