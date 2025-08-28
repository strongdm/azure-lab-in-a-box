resource "sdm_managed_secret_value" "secret" {
  value = {
    user_dn = var.user_dn
  }
  public_key = var.se_pubkey
}

resource "sdm_managed_secret" "secret" {
  name             = var.SamAccountName
  secret_engine_id = var.se_id
  value            = sdm_managed_secret_value.secret.encrypted
  tags             = var.tags
}