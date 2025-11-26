# Azure Blob Storage Read-Only Module

This module creates a service principal with read-only access to Azure Blob Storage. This is the Azure equivalent of AWS S3 read-only access.

## Features

- Azure AD application and service principal
- Storage Blob Data Reader role assignment
- Auto-rotating password (every 10 days)
- Sample storage account with container and blob for demonstration
- Integration with StrongDM for secure access management

## Usage

```hcl
module "blobro" {
  source = "../blobro"

  name         = "mylab"
  rg           = "my-resource-group"
  subscription = data.azurerm_subscription.subscription.id
  tagset       = var.tagset
}
```

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| name | Arbitrary string to add to resources | string | - |
| rg | Resource group name | string | - |
| subscription | Azure subscription ID | string | - |
| storage_account_id | Storage account ID for scoped access | string | null |
| tagset | Tags to apply to resources | map(string) | - |

## Outputs

| Name | Description |
|------|-------------|
| app_id | Azure AD application (client) ID |
| password | Service principal password (sensitive) |
| storage_account_name | Name of the created storage account |
| storage_account_id | ID of the created storage account |
| container_name | Name of the sample container |
| tags | Tags applied to resources |

## Notes

- The service principal password rotates every 10 days for security
- Re-run `terraform apply` to update the password in StrongDM after rotation
- The module creates a sample storage account; in production, you may want to grant access to existing storage accounts
