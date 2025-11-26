#--------------------------------------------------------------
# Azure Cosmos DB Module (MongoDB API)
#
# This module deploys an Azure Cosmos DB account with MongoDB API compatibility,
# which serves as a target for StrongDM to manage access to. This is the Azure
# equivalent of AWS DocumentDB.
#
# The module creates:
# - A Cosmos DB account configured for MongoDB API
# - A MongoDB database within the account
# - Firewall rules to allow access from the StrongDM relay
# - Key Vault secrets for credential storage
#--------------------------------------------------------------

# Generate a unique name for the Cosmos DB account
resource "random_pet" "cosmosdb_account_name" {
  prefix = var.name
}

# Cosmos DB Account - The main account resource configured for MongoDB API
resource "azurerm_cosmosdb_account" "mongodb" {
  name                = random_pet.cosmosdb_account_name.id
  location            = var.region
  resource_group_name = var.rg
  offer_type          = "Standard"
  kind                = "MongoDB" # MongoDB API compatibility mode

  # Enable MongoDB wire protocol and features
  capabilities {
    name = "EnableMongo"
  }

  # Use serverless capacity mode for cost efficiency in lab environments
  capabilities {
    name = "EnableServerless"
  }

  consistency_policy {
    consistency_level = "Session" # Session consistency is suitable for most scenarios
  }

  geo_location {
    location          = var.region
    failover_priority = 0
  }

  # Firewall: Allow access from the StrongDM relay IP
  ip_range_filter = var.relay_ip != null ? var.relay_ip : null

  # Allow access from Azure services (needed for some management operations)
  is_virtual_network_filter_enabled = false

  tags = local.thistagset
}

# MongoDB Database - A database within the Cosmos DB account
resource "azurerm_cosmosdb_mongo_database" "db" {
  name                = var.db_name
  resource_group_name = var.rg
  account_name        = azurerm_cosmosdb_account.mongodb.name
}

# Store Cosmos DB connection string in Azure Key Vault
resource "azurerm_key_vault_secret" "cosmosdb-connectionstring" {
  name         = "${var.name}-cosmosdb-connectionstring"
  value        = azurerm_cosmosdb_account.mongodb.primary_mongodb_connection_string
  key_vault_id = var.key_vault_id
  tags         = local.thistagset
}

# Store Cosmos DB primary key in Azure Key Vault (for reference)
resource "azurerm_key_vault_secret" "cosmosdb-primarykey" {
  name         = "${var.name}-cosmosdb-primarykey"
  value        = azurerm_cosmosdb_account.mongodb.primary_key
  key_vault_id = var.key_vault_id
  tags         = local.thistagset
}
