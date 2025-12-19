# Resource Group Module

This module creates an Azure Resource Group for the StrongDM lab environment.

## Features

- Creates a new Azure Resource Group
- Consistent tagging for resource organization

## Usage

```hcl
module "rg" {
  source = "../rg"

  name   = "mylab"
  region = "ukwest"
  tagset = var.tagset
}
```

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| name | Name prefix for resources | string | - |
| region | Azure region | string | - |
| tagset | Tags to apply to resources | map(string) | - |

## Outputs

| Name | Description |
|------|-------------|
| rgid | Resource group ID |
| rgname | Resource group name |
