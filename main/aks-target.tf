module "aks" {
    source   = "../aks"
    count    = var.create_aks == false ? 0 : 1

    tagset   = var.tagset
    name     = var.name
    region   = var.region
    rg       = coalesce(var.rg,module.rg[0].rgname)

    key_vault_id = azurerm_key_vault.sdm.id
}

resource "sdm_resource" "aks-target" {
    count    = var.create_aks == false ? 0 : 1

    aks {
        name                  = module.aks[0].name
        hostname              = module.aks[0].fqdn
        secret_store_id       = sdm_secret_store.akv.id

        certificate_authority = "${var.name}-aks-ca"
        client_key            = "${var.name}-aks-client-key"
        client_certificate    = "${var.name}-aks-client-cert"
        port                  = 443
        tags = module.aks[0].thistagset

    }
}