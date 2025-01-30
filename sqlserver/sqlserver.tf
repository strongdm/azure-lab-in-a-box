resource "random_pet" "sqlserver_server_name" {
  prefix = var.name
}
resource "azurerm_mssql_server" "server" {
  name                         = random_pet.sqlserver_server_name.id
  resource_group_name          = var.rg
  location                     = var.region
  administrator_login          = var.target_user
  administrator_login_password = local.admin_password
  version                      = "12.0"
  tags = local.thistagset

}

resource "azurerm_mssql_database" "db" {
  name      = var.dbname
  server_id = azurerm_mssql_server.server.id
}

resource "azurerm_mssql_firewall_rule" "allowgw" {
  name             = "Allow Gateways and Relays"
  server_id        = azurerm_mssql_server.server.id
  start_ip_address = var.relay_ip
  end_ip_address   = var.relay_ip
}

resource "azurerm_key_vault_secret" "sql-username" {
  name         = "${var.name}-sql-username"
  value        = var.target_user
  key_vault_id = var.key_vault_id
  tags = local.thistagset

}

resource "azurerm_key_vault_secret" "sql-password" {
  name         = "${var.name}-sql-password"
  value        = local.admin_password
  key_vault_id = var.key_vault_id
  tags = local.thistagset

}