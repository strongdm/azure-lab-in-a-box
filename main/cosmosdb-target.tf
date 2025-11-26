/*
 * Cosmos DB Target Configuration (MongoDB API)
 * Creates an Azure Cosmos DB account with MongoDB API and registers it as a resource in StrongDM
 * This is the Azure equivalent of AWS DocumentDB
 * Uses Azure Key Vault to securely store and retrieve database credentials
 */

// Create a Cosmos DB account with MongoDB API if the create_cosmosdb flag is set to true
module "cosmosdb" {
  source = "../cosmosdb"
  count  = var.create_cosmosdb == false ? 0 : 1

  tagset       = var.tagset
  name         = var.name
  relay_ip     = one(module.network[*].natip) // Allow access from the NAT gateway IP
  region       = var.region
  rg           = coalesce(var.rg, module.rg[0].rgname)
  key_vault_id = azurerm_key_vault.sdm.id

  # Ensure Key Vault permissions are ready before the module creates secrets
  depends_on = [azurerm_role_assignment.currentuser]
}

// Register the Cosmos DB account as a MongoDB resource in StrongDM
// Uses Azure Key Vault as the secret store for credentials
resource "sdm_resource" "cosmosdb-target" {
  count = var.create_cosmosdb == false ? 0 : 1
  mongo_host {
    name            = "${var.name}-cosmosdb-mongodb"
    hostname        = module.cosmosdb[0].hostname
    port            = module.cosmosdb[0].port
    username        = "${var.name}-cosmosdb-primarykey" // Key Vault secret name for the account key
    password        = "${var.name}-cosmosdb-primarykey" // Same key used for auth
    auth_database   = "admin"
    tls_required    = true // Cosmos DB requires TLS
    tags            = module.cosmosdb[0].thistagset
    secret_store_id = sdm_secret_store.akv.id
  }
}
