/*
 * Microsoft Entra ID Target Configuration
 * Creates an Entra ID resource in StrongDM for managing Azure AD group memberships
 * This enables just-in-time group membership for privilege elevation
 *
 * Prerequisites:
 * - StrongDM Enterprise plan (Entra ID is an Enterprise feature)
 * - Gateway must have Azure permissions for Entra ID group management
 * - Users need Identity Aliases configured to map to their Entra identities
 *
 * Note: The gateway's managed identity needs the following Microsoft Graph permissions:
 * - GroupMember.ReadWrite.All
 * - Group.ReadWrite.All
 * - User.Read.All
 */

# Call the entraid module to create the Azure AD application and service principal
# This grants the necessary Microsoft Graph API permissions for group management
module "entraid" {
  count  = var.create_entra_id == true ? 1 : 0
  source = "../entraid"

  name                 = var.name
  tagset               = var.tagset
  tenant_id            = data.azurerm_client_config.current.tenant_id
  subscription_id      = data.azurerm_subscription.subscription.subscription_id
  rg                   = coalesce(var.rg, one(module.rg[*].rgname))
  gateway_principal_id = azurerm_linux_virtual_machine.sdmgw.identity[0].principal_id
}

# Identity Set for Entra ID - maps StrongDM users to their Entra identities
resource "sdm_identity_set" "entraid" {
  count = var.create_entra_id == true ? 1 : 0
  name  = "${var.name}-entra-identity-set"
}

# StrongDM Entra ID resource for group management
# Enables just-in-time privilege elevation via Entra ID group membership
resource "sdm_resource" "entraid" {
  count = var.create_entra_id == true ? 1 : 0

  entra_id {
    name            = "${var.name}-entra-id"
    tenant_id       = data.azurerm_client_config.current.tenant_id
    identity_set_id = one(sdm_identity_set.entraid[*].id)

    # Optional: Filter to specific groups (comma-separated, supports wildcards)
    # group_names = "Admins,*-ReadOnly,DevOps-*"

    # Optional: Define privilege levels that map to Entra ID groups
    # privilege_levels = "Owner,Contributor,Reader"

    tags = merge(var.tagset, {
      network = "Public"
      class   = "target"
    })
  }
}
