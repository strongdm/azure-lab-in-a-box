#--------------------------------------------------------------
# Azure Data Factory Module
#
# This module creates a service principal with full access to Azure Data Factory.
# This is the Azure equivalent of AWS Glue full access.
#
# The module creates:
# - An Azure AD application
# - A service principal for the application
# - A rotating password for the service principal
# - Role assignment for Data Factory Contributor
# - A sample Data Factory instance for demonstration
#--------------------------------------------------------------

data "azuread_client_config" "current" {}

# Create an Azure AD application for Data Factory full access
resource "azuread_application" "datafactory" {
  display_name = "${var.name}-SDM-DataFactory-Full"
  owners       = [data.azuread_client_config.current.object_id]

  feature_tags {
    enterprise            = false
    gallery               = false
    custom_single_sign_on = false
    hide                  = false
  }
}

# Create the service principal
resource "azuread_service_principal" "datafactory" {
  client_id                    = azuread_application.datafactory.client_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]

  feature_tags {
    enterprise            = false
    gallery               = false
    custom_single_sign_on = false
    hide                  = false
  }
}

# Rotate password every 10 days for security
resource "time_rotating" "datafactory" {
  rotation_days = 10
}

# Create a password for the service principal
resource "azuread_service_principal_password" "datafactory" {
  service_principal_id = azuread_service_principal.datafactory.id
  rotate_when_changed = {
    rotation = time_rotating.datafactory.id
  }
}

# Generate a unique name for the Data Factory
resource "random_pet" "datafactory" {
  prefix    = var.name
  separator = ""
  length    = 1
}

# Create a Data Factory instance for demonstration
resource "azurerm_data_factory" "sample" {
  name                = substr(replace(random_pet.datafactory.id, "-", ""), 0, 63)
  location            = var.region
  resource_group_name = var.rg

  identity {
    type = "SystemAssigned"
  }

  tags = local.thistagset
}

# Assign Data Factory Contributor role to the service principal
resource "azurerm_role_assignment" "datafactory_contributor" {
  principal_id         = azuread_service_principal.datafactory.object_id
  role_definition_name = "Data Factory Contributor"
  scope                = azurerm_data_factory.sample.id
}

# Also assign Reader role at resource group level for discovery
resource "azurerm_role_assignment" "datafactory_reader" {
  principal_id         = azuread_service_principal.datafactory.object_id
  role_definition_name = "Reader"
  scope                = "${var.subscription}/resourceGroups/${var.rg}"
}
