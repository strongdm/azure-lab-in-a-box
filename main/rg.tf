/*
 * Resource Group Configuration - Main Module
 * Conditionally creates a new resource group for the StrongDM lab environment
 * Only creates a resource group if var.rg is not provided
 */

// Create a resource group if var.rg is null (not specified)
module "rg" {
    count  = var.rg == null ? 1:0
    source = "../rg"
    name   = var.name
    region = var.region
    tagset = var.tagset
}