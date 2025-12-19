# Azure Read-Only Module

This module creates a service principal with read-only access to Azure resources for StrongDM CLI access.

## Features

- Azure AD application and service principal
- Reader role assignment at subscription level
- Auto-rotating password (every 10 days)
- Integration with StrongDM for secure access management

## Usage

```hcl
module "azro" {
  source = "../azro"

  name         = "mylab"
  rg           = "my-resource-group"
  subscription = data.azurerm_subscription.subscription.id
  tagset       = var.tagset
}
```

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| name | Name prefix for resources | string | - |
| rg | Resource group name | string | - |
| subscription | Azure subscription ID | string | - |
| tagset | Tags to apply to resources | map(string) | - |

## Outputs

| Name | Description |
|------|-------------|
| app_id | Azure AD application (client) ID |
| password | Service principal password (sensitive) |
| tags | Tags applied to resources |

## Notes

- Service principal password rotates every 10 days
- Re-run `terraform apply` to update the password in StrongDM after rotation
