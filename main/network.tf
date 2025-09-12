/*
 * Network Configuration - Main Module
 * Conditionally creates a new network environment for the StrongDM lab
 * Only creates network resources if var.vn is not provided
 */

// Create network resources if var.vn is null (not specified)
module "network" {
  count  = var.vn == null ? 1 : 0
  source = "../network"

  rg            = coalesce(var.rg, one(module.rg[*].rgname))
  region        = var.region
  tagset        = var.tagset
  name          = var.name
  strongdm_port = local.strongdm_gateway_port
}