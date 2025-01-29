module "dc" {
    source      = "../dc"
    count       = var.create_domain_controller == false ? 0 : 1
    tagset      = var.tagset
    name        = var.name
    subnet      = coalesce(var.relay_subnet,one(module.network[*].relay_subnet))
    rg          = coalesce(var.rg,module.rg[0].rgname)
    region      = var.region
}

resource "sdm_resource" "dc" {
    count = var.create_domain_controller == false ? 0 : 1
    rdp {
        name     = "domain-controller"
        hostname = one(module.dc[*].dc_ip)
        username = one(module.dc[*].dc_username)
        password = one(module.dc[*].dc_password)

        port = 3389
        tags = one(module.dc[*].thistagset)

    }
}