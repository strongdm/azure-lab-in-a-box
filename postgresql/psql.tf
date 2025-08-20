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
resource "azurerm_postgresql_flexible_server" "server" {
  name                = random_pet.azurerm_postgresql_server_name.id
  location            = var.region
  resource_group_name = var.rg
  administrator_login          = var.target_user
  administrator_password = local.admin_password
  public_network_access_enabled = true

  // Basic tier with minimal resources for lab/demo purposes
  sku_name   = "B_Standard_B2s"
  version    = "15"
  storage_mb = 32768

  tags = local.thistagset
}

// Firewall rule to allow access from the StrongDM relay
resource "azurerm_postgresql_flexible_server_firewall_rule" "allowgw" {
  name                = "AllowGatewaysAndRelays"
  server_id         = azurerm_postgresql_flexible_server.server.id
  start_ip_address    = var.relay_ip
  end_ip_address      = var.relay_ip
}

// Store PostgreSQL username in Azure Key Vault
resource "azurerm_key_vault_secret" "psql-username" {
  name         = "${var.name}-psql-username"
  value        = "${var.target_user}"
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