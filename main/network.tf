module "network" {
  count  = var.vn == null ? 1 : 0
  source = "../network"
  
  rg     = coalesce(var.rg,one(module.rg[*].rgname))
  region = var.region
  tagset = var.tagset
  name   = var.name
}