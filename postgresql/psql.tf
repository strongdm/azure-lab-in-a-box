/*
 * PostgreSQL Server Module
 * Creates a PostgreSQL single server instance in Azure with firewall rules to allow access from the relay
 * Stores credentials in Azure Key Vault for secure retrieval
 */

// Generate a unique name for the PostgreSQL server
resource "random_pet" "azurerm_postgresql_server_name" {
  prefix = var.name
}

// Create a PostgreSQL server in Azure
resource "azurerm_postgresql_server" "server" {
  name                = random_pet.azurerm_postgresql_server_name.id
  location            = var.region
  resource_group_name = var.rg
  administrator_login          = var.target_user
  administrator_login_password = local.admin_password

  // Basic tier with minimal resources for lab/demo purposes
  sku_name   = "B_Gen5_1"
  version    = "11"
  storage_mb = 5120

  infrastructure_encryption_enabled = false

  public_network_access_enabled    = true
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"
  geo_redundant_backup_enabled = false

  tags = local.thistagset
}

// Firewall rule to allow access from the StrongDM relay
resource "azurerm_postgresql_firewall_rule" "allowgw" {
  name                = "AllowGatewaysAndRelays"
  server_name         = azurerm_postgresql_server.server.name
  resource_group_name = var.rg
  start_ip_address    = var.relay_ip
  end_ip_address      = var.relay_ip
}

// Store PostgreSQL username in Azure Key Vault
resource "azurerm_key_vault_secret" "psql-username" {
  name         = "${var.name}-psql-username"
  value        = "${var.target_user}@${random_pet.azurerm_postgresql_server_name.id}"
  key_vault_id = var.key_vault_id
  tags = local.thistagset
}

// Store PostgreSQL password in Azure Key Vault
resource "azurerm_key_vault_secret" "psql-password" {
  name         = "${var.name}-psql-password"
  value        = local.admin_password
  key_vault_id = var.key_vault_id
  tags = local.thistagset
}