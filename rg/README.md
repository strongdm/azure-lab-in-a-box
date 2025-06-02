# Resource Group Module for StrongDM Azure Lab

## Overview

This module creates an Azure Resource Group that serves as the logical container for all StrongDM lab resources. It provides the foundational organizational structure for the lab environment, enabling consistent resource management, access control, and cost tracking.

## Architecture

The module provisions:
- Azure Resource Group with specified name and location
- Consistent tagging for resource organization and management
- Foundation for all other lab modules to deploy resources

## Features

- **Logical Grouping**: Contains all lab resources in a single manageable unit
- **Consistent Tagging**: Applies standardized tags for organization and cost tracking
- **Access Control**: Enables role-based access control at the resource group level
- **Cost Management**: Facilitates cost tracking and budgeting for lab resources
- **Resource Lifecycle**: Simplifies cleanup by allowing deletion of entire resource group

## Use Cases for Partner Training

1. **Azure Organization**: Demonstrate Azure resource organization best practices
2. **Access Control**: Show how RBAC works at the resource group level
3. **Cost Management**: Illustrate cost tracking and resource management
4. **Resource Lifecycle**: Demonstrate easy cleanup and resource management
5. **Tagging Strategy**: Show consistent tagging across all resources

## Configuration

### Basic Usage

```hcl
module "resource_group" {
  source  = "../rg"
  name    = "${var.name}-lab-rg"
  region  = var.region
  tagset  = var.tagset
}
```

### Required Variables

- `name`: Name for the resource group (should be descriptive and unique)
- `region`: Azure region where the resource group will be created
- `tagset`: Tags to apply to the resource group

## Resource Group Naming

The resource group name should follow Azure naming conventions:
- Must be unique within the Azure subscription
- Can contain alphanumeric characters, periods, underscores, hyphens, and parentheses
- Cannot end with a period
- Maximum length of 90 characters

## Tagging Strategy

The module applies a comprehensive tagging strategy that includes:
- **Standard Tags**: Applied from the tagset variable
- **Resource Class**: Tagged as "sdminfra" for identification
- **Environment Information**: Lab environment designation
- **Owner Information**: Contact information for resource management

Example tagset:
```hcl
tagset = {
  environment = "Lab"
  customer    = "Partners" 
  sdm-owner   = "admin@strongdm.com"
  cloud       = "Azure"
  purpose     = "StrongDM Training"
}
```

## Security Features

1. **RBAC Integration**: Resource group enables fine-grained access control
2. **Resource Isolation**: Isolates lab resources from other Azure resources
3. **Policy Application**: Allows application of Azure policies at the group level
4. **Audit Logging**: All resource group operations are logged for compliance

## Cost Management

Benefits for cost tracking:
- **Unified Billing**: All lab costs grouped together
- **Budget Alerts**: Can set spending alerts at resource group level
- **Cost Analysis**: Easy analysis of lab resource costs
- **Resource Cleanup**: Simple deletion of all resources at once

## Generated Resources

The module creates:
- Azure Resource Group with specified configuration
- Applied tags for resource management
- Foundation for all subsequent module deployments

## Outputs

- `resource_group_name`: Name of the created resource group
- `resource_group_id`: Azure resource ID of the resource group
- `location`: Azure region where the resource group was created

## Integration with Other Modules

This module is typically the first module deployed and provides the foundation for all other modules:

```hcl
# Deploy resource group first
module "resource_group" {
  source = "../rg"
  name   = "${var.name}-lab"
  region = var.region
  tagset = var.tagset
}

# Other modules reference the resource group
module "network" {
  source = "../network"
  rg     = module.resource_group.resource_group_name
  # ... other variables
}
```

## Resource Group Lifecycle

### Creation
- Resource group is created with specified name and location
- Tags are applied for organization and management
- Provides foundation for all other resources

### Management
- All lab resources are contained within this resource group
- Access control applied at resource group level
- Cost tracking and budgeting enabled

### Cleanup
- Deleting the resource group removes all contained resources
- Provides easy cleanup mechanism for lab environment
- Ensures no orphaned resources remain

## Best Practices

1. **Naming Convention**: Use descriptive names that identify the lab purpose
2. **Tagging Strategy**: Apply consistent tags across all resources
3. **Access Control**: Set appropriate RBAC permissions at resource group level
4. **Cost Monitoring**: Set up cost alerts and budgets for the resource group
5. **Documentation**: Document the purpose and contents of the resource group

## Important Notes

- ⚠️ **Deletion Impact**: Deleting the resource group removes ALL contained resources
- ⚠️ **Naming Uniqueness**: Resource group names must be unique within the subscription
- ⚠️ **Regional Placement**: Choose region carefully as it affects resource availability and costs
- ⚠️ **Tag Inheritance**: Resources within the group can inherit tags from the resource group
