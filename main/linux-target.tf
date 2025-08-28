/*
 * Linux Target Configuration
 * Creates a Linux VM target and registers it in StrongDM using SSH certificate authentication
 * Uses the StrongDM SSH CA for secure certificate-based authentication
 */

// Create a Linux VM if the create_linux_target flag is set to true
module "linux-target" {
  source  = "../linux-target"
  count   = var.create_linux_target == false ? 0 : 1
  rg      = coalesce(var.rg, one(module.rg[*].rgname))
  sshca   = data.sdm_ssh_ca_pubkey.ssh_pubkey_query.public_key
  tagset  = var.tagset
  name    = var.name
  subnet  = coalesce(var.relay_subnet, one(module.network[*].relay_subnet))
  vm_size = var.vm_sizes.linux_target
}

// Register the Linux VM as a resource in StrongDM using certificate authentication
resource "sdm_resource" "ssh-ca-target" {
  count      = var.create_linux_target == false ? 0 : 1
  depends_on = [module.linux-target]
  ssh_cert {
    name     = "${var.name}-ssh-ca-target"
    hostname = one(module.linux-target[*].ip)
    username = one(module.linux-target[*].target_user)
    port     = 22
    tags     = one(module.linux-target[*].tagset)
  }
}