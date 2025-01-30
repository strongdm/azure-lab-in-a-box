module "linux-target" {
    source = "../linux-target"
    count  = var.create_linux_target == false ? 0 : 1
    rg     = coalesce(var.rg,one(module.rg[*].rgname))
    sshca  = data.sdm_ssh_ca_pubkey.ssh_pubkey_query.public_key
    tagset = var.tagset
    name   = var.name
    subnet = coalesce(var.relay_subnet,one(module.network[*].relay_subnet))

}

resource "sdm_resource" "ssh-ca-target" {
    count = var.create_linux_target == false ? 0 : 1
    depends_on = [ module.linux-target ]
    ssh_cert {
        name     = "ssh-ca-target"
        hostname = one(module.linux-target[*].ip)
        username = one(module.linux-target[*].target_user)
        port     = 22
        tags = one(module.linux-target[*].tagset)

    }
}