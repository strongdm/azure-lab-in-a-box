# Azure Data Factory Module

This module creates a service principal with full access to Azure Data Factory. This is the Azure equivalent of AWS Glue full access.

## Features

- Azure AD application and service principal
- Data Factory Contributor role assignment
- Auto-rotating password (every 10 days)
- Sample Data Factory instance for demonstration
- Integration with StrongDM for secure access management

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
| name | Arbitrary string to add to resources | string | - |
| region | Azure region for Data Factory | string | - |
| rg | Resource group name | string | - |
| subscription | Azure subscription ID | string | - |
| tagset | Tags to apply to resources | map(string) | - |

## Outputs

| Name | Description |
|------|-------------|
| app_id | Azure AD application (client) ID |
| password | Service principal password (sensitive) |
| data_factory_name | Name of the created Data Factory |
| data_factory_id | ID of the created Data Factory |
| tags | Tags applied to resources |

## Notes

- The service principal password rotates every 10 days for security
- Re-run `terraform apply` to update the password in StrongDM after rotation
- The Data Factory Contributor role provides full access to manage Data Factory resources
- A sample Data Factory is created; users can create pipelines, datasets, and linked services
- Azure Data Factory is the Azure equivalent of AWS Glue for ETL/data integration workloads
