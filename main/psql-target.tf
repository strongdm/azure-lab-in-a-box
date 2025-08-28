/*
 * PostgreSQL Target Configuration
 * Creates a PostgreSQL server using the PostgreSQL module and registers it as a resource in StrongDM
 * Uses Azure Key Vault to securely store and retrieve database credentials
 */

// Create a PostgreSQL server if the create_postgresql flag is set to true
module "postgresql" {
  source = "../postgresql"
  count  = var.create_postgresql == false ? 0 : 1

  tagset   = var.tagset
  name     = var.name
  relay_ip = one(module.network[*].natip) // Allow access from the NAT gateway IP
  region   = var.region
  subnet   = coalesce(var.relay_subnet, one(module.network[*].relay_subnet))
  rg       = coalesce(var.rg, module.rg[0].rgname)

  key_vault_id = azurerm_key_vault.sdm.id
}

// Register the PostgreSQL server as a resource in StrongDM
// Uses Azure Key Vault as the secret store for credentials
resource "sdm_resource" "pgsqlserver" {
  count      = var.create_postgresql == false ? 0 : 1
  depends_on = [module.postgresql]
  postgres {
    database = "postgres"
    name     = "${var.name}-psql-server"
    // References to credentials stored in Azure Key Vault
    password        = "${var.name}-psql-password"
    port            = 5432
    username        = "${var.name}-psql-username"
    hostname        = module.postgresql[0].fqdn
    tags            = module.postgresql[0].thistagset
    secret_store_id = sdm_secret_store.akv.id
  }
}