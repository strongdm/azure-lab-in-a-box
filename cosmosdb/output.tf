#--------------------------------------------------------------
# Cosmos DB Module Outputs
#
# This file defines the output values from the Cosmos DB module that other
# modules and resources need to reference. These outputs provide connection
# endpoints, credentials, and resource identifiers needed for StrongDM
# integration and database access configuration.
#--------------------------------------------------------------

output "endpoint" {
  description = "Endpoint for the Cosmos DB account"
  value       = azurerm_cosmosdb_account.mongodb.endpoint
}

output "mongodb_connection_string" {
  description = "Primary MongoDB connection string for the Cosmos DB account"
  value       = azurerm_cosmosdb_account.mongodb.primary_mongodb_connection_string
  sensitive   = true
}

output "hostname" {
  description = "Hostname extracted from the Cosmos DB endpoint for MongoDB connections"
  value       = "${azurerm_cosmosdb_account.mongodb.name}.mongo.cosmos.azure.com"
}

output "port" {
  description = "Port for MongoDB connections to Cosmos DB"
  value       = 10255
}

output "account_name" {
  description = "The name of the Cosmos DB account (used as username)"
  value       = azurerm_cosmosdb_account.mongodb.name
}

output "primary_key" {
  description = "Primary key for the Cosmos DB account (used as password)"
  value       = azurerm_cosmosdb_account.mongodb.primary_key
  sensitive   = true
}

output "database_name" {
  description = "Name of the MongoDB database"
  value       = azurerm_cosmosdb_mongo_database.db.name
}

output "thistagset" {
  description = "Tags applied to Cosmos DB resources (used by StrongDM resource definitions)"
  value       = local.thistagset
}

output "account_id" {
  description = "Cosmos DB account ID"
  value       = azurerm_cosmosdb_account.mongodb.id
}
