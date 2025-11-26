module "secretsmgmt" {
  source = "../secretsmgmt"
  for_each = { for index, user in(var.create_managedsecrets ? (coalesce(var.domain_users, [])) : []) :
    user.SamAccountName => user
  }
  se_pubkey      = sdm_secret_engine.ad[0].active_directory[0].public_key
  se_id          = sdm_secret_engine.ad[0].id
  user_dn        = "cn=${each.value.GivenName} ${each.value.Surname},cn=Users,dc=${var.name},dc=local"
  tags           = each.value.tags
  SamAccountName = each.value.SamAccountName

  # Ensure secret engine is fully created with valid public key
  depends_on = [sdm_secret_engine.ad]
}

resource "sdm_secret_engine" "ad" {
  count = var.create_domain_controller ? 1 : 0
  # Note: This resource requires the Domain Controller to be fully configured with LDAP services
  # For reliable deployment, run with create_managedsecrets=false first, then enable after DC setup
  depends_on = [sdm_node.relay]
  active_directory {
    binddn                 = "CN=${one(module.dc[*].domain_admin)},CN=Users,DC=${var.name},DC=local"
    bindpass               = one(module.dc[*].domain_password)
    insecure_tls           = true
    name                   = "${var.name}AD"
    secret_store_id        = resource.sdm_secret_store.akv.id
    secret_store_root_path = "${var.name}AD"
    url                    = "ldaps://${one(module.dc[*].dc_ip)}/"
    max_backoff_duration   = "24h0m0s"
    tags = {
      "eng__${var.name}AD" = "true"
    }
  }
}
