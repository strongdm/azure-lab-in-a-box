module "windowstarget" {
  source = "../windowstarget"
  count  = var.create_windows_target == false ? 0 : 1
  tagset = var.tagset
  name   = var.name
  region = var.region
  subnet = coalesce(var.relay_subnet, one(module.network[*].relay_subnet))
  rg     = coalesce(var.rg, module.rg[0].rgname)
  dns    = one(module.dc[*].dc_ip)

  domain_password = one(module.dc[*].domain_password)

  domain_admin = (one(module.dc[*].domain_admin))
  domain_name  = (one(module.dc[*].netbios_domain))
  vm_size      = var.vm_sizes.windows_target

  # Ensure domain controller is fully configured before creating Windows target
  depends_on = [module.dc]
}

resource "sdm_resource" "windows-target" {
  count = var.create_windows_target == false ? 0 : 1
  rdp {
    name     = "${var.name}-windows-password"
    hostname = one(module.windowstarget[*].ip)
    username = one(module.windowstarget[*].username)
    password = one(module.windowstarget[*].password)

    port = 3389
    tags = one(module.windowstarget[*].thistagset)

  }
}

resource "sdm_resource" "windows-target-rdp" {
  count = var.create_windows_target == false ? 0 : 1
  rdp_cert {
    name     = "${var.name}-windows-ca"
    hostname = one(module.windowstarget[*].ip)
    username = "${(one(module.dc[*].netbios_domain))}\\${(one(module.dc[*].domain_admin))}"

    port = 3389
    tags = one(module.windowstarget[*].thistagset)
  }
}
