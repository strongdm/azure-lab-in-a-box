data "azuread_client_config" "current" {}

# Create an Azure AD application
resource "azuread_application" "sdm" {
  display_name = "${var.name}-SDM-ReadOnly"
  owners       = [data.azuread_client_config.current.object_id]
  feature_tags {
    enterprise            = false
    gallery               = false
    custom_single_sign_on = false
    hide                  = false
  }

}

# Create the service principal
resource "azuread_service_principal" "sdm" {
  client_id                    = azuread_application.sdm.client_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]

  feature_tags {
    enterprise            = false
    gallery               = false
    custom_single_sign_on = false
    hide                  = false
  }
}

resource "time_rotating" "sdm" {
  rotation_days = 10
}

resource "azuread_service_principal_password" "sdm" {
  service_principal_id = azuread_service_principal.sdm.id
  rotate_when_changed = {
    rotation = time_rotating.sdm.id
  }
}

# Assign the Reader role to the service principal (read-only permissions)
resource "azurerm_role_assignment" "sdm" {
  principal_id         = azuread_service_principal.sdm.object_id
  role_definition_name = "Reader" # Built-in Read-only role
  scope                = "${var.subscription}/resourceGroups/${var.rg}"
}
