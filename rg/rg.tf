/*
 * Resource Group Module
 * Creates an Azure resource group to contain all lab resources
 * Resource groups provide a logical container for Azure resources
 * and simplify resource management and access control
 */

// Create an Azure resource group with the specified name and location
resource "azurerm_resource_group" "rg" {
  name     = var.name
  location = var.region
  tags     = local.thistagset
}