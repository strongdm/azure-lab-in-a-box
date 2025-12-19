# Azure Blob Storage Read-Only Module

This module creates a service principal with read-only access to Azure Blob Storage.

## Features

- Azure AD application and service principal
- Storage Blob Data Reader role assignment
- Auto-rotating password (every 10 days)
- Sample storage account with container

## Usage

```hcl
module "blobro" {
  source = "../azblobro"

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
| storage_account_id | Existing storage account ID | string | null |

## Outputs

| Name | Description |
|------|-------------|
| app_id | Azure AD application (client) ID |
| password | Service principal password (sensitive) |
| storage_account_name | Created storage account name |
| storage_account_id | Created storage account ID |
| container_name | Sample container name |
| tags | Tags applied to resources |

## Notes

- Service principal password rotates every 10 days
- Re-run `terraform apply` to update the password in StrongDM after rotation
