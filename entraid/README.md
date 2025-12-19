# Entra ID Module

This module creates the Azure AD/Entra ID application and service principal required for StrongDM to manage Entra ID group memberships.

## Overview

The Entra ID resource in StrongDM enables just-in-time privilege elevation by dynamically managing Entra ID group memberships. This allows time-bound access to:
- Entra ID admin roles
- Azure IaaS console roles
- Microsoft 365 admin roles

## Prerequisites

- **StrongDM Enterprise plan** - Entra ID is an Enterprise-tier feature
- **Azure permissions** - The identity running Terraform needs:
  - Application Administrator or Global Administrator role to create apps and grant admin consent
- **Identity Aliases** - Users need Identity Aliases configured to map to their Entra identities

## Resources Created

| Resource | Description |
|----------|-------------|
| `azuread_application` | Azure AD application for StrongDM |
| `azuread_service_principal` | Service principal for the application |
| `azuread_service_principal_password` | Rotating password (10-day rotation) |
| `azuread_app_role_assignment` | Admin consent for Graph API permissions |

## Microsoft Graph API Permissions

The following application permissions are granted:

| Permission | Description |
|------------|-------------|
| `GroupMember.ReadWrite.All` | Read and write all group memberships |
| `Group.ReadWrite.All` | Read and write all groups |
| `User.Read.All` | Read all users (for identity resolution) |

## Usage

```hcl
module "entraid" {
  source = "../entraid"

  name                 = "mylab"
  tagset               = { environment = "lab" }
  tenant_id            = data.azurerm_client_config.current.tenant_id
  subscription_id      = data.azurerm_subscription.subscription.subscription_id
  rg                   = azurerm_resource_group.main.name
  gateway_principal_id = azurerm_linux_virtual_machine.gateway.identity[0].principal_id
}
```

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| `name` | Prefix for resource names | `string` | yes |
| `tagset` | Tags for StrongDM resources | `map(string)` | yes |
| `tenant_id` | Azure AD tenant ID | `string` | yes |
| `subscription_id` | Azure subscription ID | `string` | yes |
| `rg` | Resource group name | `string` | yes |
| `gateway_principal_id` | Gateway managed identity principal ID | `string` | yes |

## Outputs

| Name | Description |
|------|-------------|
| `app_id` | Application (client) ID |
| `password` | Service principal password (sensitive) |
| `object_id` | Service principal object ID |
| `tags` | Tags for the StrongDM resource |

## Admin Consent

The module attempts to grant admin consent automatically via `azuread_app_role_assignment` resources. If the Terraform execution identity lacks sufficient permissions, you may need to grant admin consent manually in the Azure portal:

1. Navigate to Azure Active Directory > App registrations
2. Find the application named `{name}-SDM-EntraID`
3. Go to API permissions
4. Click "Grant admin consent for {tenant}"

## Password Rotation

The service principal password rotates every 10 days. Run `terraform apply` regularly to ensure the password stays current, or the StrongDM resource will lose access.

## Related Documentation

- [Microsoft Entra ID | StrongDM Docs](https://docs.strongdm.com/admin/resources/clouds/microsoft-entra-id)
- [Identity Sets | StrongDM Docs](https://docs.strongdm.com/admin/principals/identity-alias)
- [StrongDM Terraform Provider](https://registry.terraform.io/providers/strongdm/sdm/latest/docs)
