# Azure Data Factory Module

This module creates a service principal with full access to Azure Data Factory.

## Features

- Azure AD application and service principal
- Data Factory Contributor role assignment
- Auto-rotating password (every 10 days)
- Sample Data Factory instance

## Usage

```hcl
module "datafactory" {
  source = "../datafactory"

  name         = "mylab"
  region       = "ukwest"
  rg           = "my-resource-group"
  subscription = data.azurerm_subscription.subscription.id
  tagset       = var.tagset
}
```

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| name | Name prefix for resources | string | - |
| region | Azure region | string | - |
| rg | Resource group name | string | - |
| subscription | Azure subscription ID | string | - |
| tagset | Tags to apply to resources | map(string) | - |

## Outputs

| Name | Description |
|------|-------------|
| app_id | Azure AD application (client) ID |
| password | Service principal password (sensitive) |
| data_factory_name | Created Data Factory name |
| data_factory_id | Created Data Factory ID |
| tags | Tags applied to resources |

## Notes

- Service principal password rotates every 10 days
- Azure Data Factory is the Azure equivalent of AWS Glue
