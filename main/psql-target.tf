module "postgresql" {
    source   = "../postgresql"
    count       = var.create_postgresql == false ? 0 : 1

    tagset   = var.tagset
    name     = var.name
    relay_ip = one(module.network[*].natip)
    region   = var.region
    subnet   = coalesce(var.relay_subnet,one(module.network[*].relay_subnet))
    rg       = coalesce(var.rg,module.rg[0].rgname)

    key_vault_id = azurerm_key_vault.sdm.id
}

resource "sdm_resource" "pgsqlserver" {
    count       = var.create_postgresql == false ? 0 : 1
    depends_on = [ module.postgresql ]
    postgres {
        database = "postgres"
        name     = "psql-server"
        password = "${var.name}-psql-password"
        port     = 5432
        username = "${var.name}-psql-username"
        hostname = module.postgresql[0].fqdn
        tags = module.postgresql[0].thistagset
        secret_store_id = sdm_secret_store.akv.id
    }
}