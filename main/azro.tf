module "azro" {
    count  = var.create_az_ro == true ? 1:0
    source = "../azro"
    name   = var.name
    tagset = var.tagset
    rg     = coalesce(var.rg,one(module.rg[*].rgname))

    subscription = data.azurerm_subscription.subscription.id

}

resource "sdm_resource" "azro" {
    count  = var.create_az_ro == true ? 1:0
    azure {
        name   = "${var.name}-azure-readonly"
        app_id = one(module.azro[*].app_id)
        tags   = one(module.azro[*].tags)

        password  = one(module.azro[*].password)
        tenant_id = "${data.azurerm_client_config.current.tenant_id}"
    }
}