#TODO: Fix RGID for pre-existing RG
module "hcvault" {
  source  = "../hcvault"
  count   = var.create_hcvault == false ? 0 : 1
  rg      = coalesce(var.rg, one(module.rg[*].rgname))
  sshca   = data.sdm_ssh_ca_pubkey.ssh_pubkey_query.public_key
  tagset  = var.tagset
  name    = var.name
  subnet  = coalesce(var.relay_subnet, one(module.network[*].relay_subnet))
  akvid   = azurerm_key_vault.sdm.id
  akvdns  = azurerm_key_vault.sdm.name
  rgid    = one(module.rg[*].rgid)
  vm_size = var.vm_sizes.vault

}

resource "sdm_resource" "ssh-hcvault" {
  count      = var.create_hcvault == false ? 0 : 1
  depends_on = [module.hcvault]
  ssh_cert {
    name     = "${var.name}-hcvault"
    hostname = one(module.hcvault[*].ip)
    username = one(module.hcvault[*].target_user)
    port     = 22
    tags     = one(module.hcvault[*].tagset)

  }
}

resource "sdm_secret_store" "hcvault" {
  count = var.create_hcvault == false ? 0 : 1
  vault_token {
    name           = "HashiCorp Vault ${var.name}"
    tags           = var.tagset
    server_address = "http://${one(module.hcvault[*].ip)}:8200"
  }
}