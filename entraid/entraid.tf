/*
 * Entra ID Module
 * Creates Azure AD/Entra ID application and service principal with permissions
 * for StrongDM to manage Entra ID group memberships
 */

data "azuread_client_config" "current" {}

# Microsoft Graph API application ID (constant across all tenants)
data "azuread_application_published_app_ids" "well_known" {}

data "azuread_service_principal" "msgraph" {
  client_id = data.azuread_application_published_app_ids.well_known.result["MicrosoftGraph"]
}

# Create an Azure AD application for StrongDM Entra ID management
resource "azuread_application" "entraid" {
  display_name = "${var.name}-SDM-EntraID"
  owners       = [data.azuread_client_config.current.object_id]

  # Required Microsoft Graph API permissions for group management
  required_resource_access {
    resource_app_id = data.azuread_application_published_app_ids.well_known.result["MicrosoftGraph"]

    # GroupMember.ReadWrite.All - Read and write all group memberships
    resource_access {
      id   = data.azuread_service_principal.msgraph.app_role_ids["GroupMember.ReadWrite.All"]
      type = "Role"
    }

    # Group.ReadWrite.All - Read and write all groups
    resource_access {
      id   = data.azuread_service_principal.msgraph.app_role_ids["Group.ReadWrite.All"]
      type = "Role"
    }

    # User.Read.All - Read all users (needed to resolve user identities)
    resource_access {
      id   = data.azuread_service_principal.msgraph.app_role_ids["User.Read.All"]
      type = "Role"
    }
  }

  feature_tags {
    enterprise            = false
    gallery               = false
    custom_single_sign_on = false
    hide                  = false
  }
}

# Create the service principal for the application
resource "azuread_service_principal" "entraid" {
  client_id                    = azuread_application.entraid.client_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]

  feature_tags {
    enterprise            = false
    gallery               = false
    custom_single_sign_on = false
    hide                  = false
  }
}

# Rotate password every 10 days
resource "time_rotating" "entraid" {
  rotation_days = 10
}

# Create service principal password/secret
resource "azuread_service_principal_password" "entraid" {
  service_principal_id = azuread_service_principal.entraid.id
  rotate_when_changed = {
    rotation = time_rotating.entraid.id
  }
}

# Grant admin consent for the application permissions
# Note: These require admin consent which may need to be done manually in Azure portal
# if the terraform execution identity doesn't have Global Admin or Privileged Role Admin

resource "azuread_app_role_assignment" "group_member_readwrite" {
  app_role_id         = data.azuread_service_principal.msgraph.app_role_ids["GroupMember.ReadWrite.All"]
  principal_object_id = azuread_service_principal.entraid.object_id
  resource_object_id  = data.azuread_service_principal.msgraph.object_id
}

resource "azuread_app_role_assignment" "group_readwrite" {
  app_role_id         = data.azuread_service_principal.msgraph.app_role_ids["Group.ReadWrite.All"]
  principal_object_id = azuread_service_principal.entraid.object_id
  resource_object_id  = data.azuread_service_principal.msgraph.object_id
}

resource "azuread_app_role_assignment" "user_read" {
  app_role_id         = data.azuread_service_principal.msgraph.app_role_ids["User.Read.All"]
  principal_object_id = azuread_service_principal.entraid.object_id
  resource_object_id  = data.azuread_service_principal.msgraph.object_id
}
