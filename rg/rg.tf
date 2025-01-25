resource "azurerm_resource_group" "rg" {
  name     = var.name
  location = var.region
  tags = local.thistagset
}