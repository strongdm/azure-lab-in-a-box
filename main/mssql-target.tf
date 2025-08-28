module "sqlserver" {
  source = "../sqlserver"
  count  = var.create_mssql == false ? 0 : 1

  tagset   = var.tagset
  name     = var.name
  relay_ip = one(module.network[*].natip)
  region   = var.region
  subnet   = coalesce(var.relay_subnet, one(module.network[*].relay_subnet))
  rg       = coalesce(var.rg, module.rg[0].rgname)

  key_vault_id = azurerm_key_vault.sdm.id
}

resource "sdm_resource" "sqlserver" {
  count      = var.create_mssql == false ? 0 : 1
  depends_on = [module.sqlserver]

  sql_server {
    database        = module.sqlserver[0].dbname
    name            = "mssql-server"
    password        = "${var.name}-sql-password"
    port            = 1433
    username        = "${var.name}-sql-username"
    hostname        = module.sqlserver[0].fqdn
    tags            = module.sqlserver[0].thistagset
    secret_store_id = sdm_secret_store.akv.id
  }
}