# SQL Server Module

This module creates an Azure SQL Database for StrongDM access demonstrations.

## Features

- Azure SQL Database server
- Credentials stored in Azure Key Vault
- Firewall rules for StrongDM relay access
- TLS encryption for connections

## Usage

```hcl
module "sqlserver" {
  source = "../sqlserver"

  name         = "mylab"
  region       = "ukwest"
  rg           = "my-resource-group"
  relay_ip     = module.relay.ip
  key_vault_id = azurerm_key_vault.sdm.id
  tagset       = var.tagset
}
```

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| name | Name prefix for resources | string | - |
| region | Azure region | string | - |
| rg | Resource group name | string | null |
| tagset | Tags to apply to resources | map(string) | - |
| relay_ip | Relay IP for firewall rules | string | null |
| key_vault_id | Key Vault ID for credentials | string | null |
| target_user | Database admin username | string | "sqlserver" |
| dbname | Database name to create | string | "labdb" |
| subnet | Subnet ID for VNet integration | string | null |

## Outputs

| Name | Description |
|------|-------------|
| fqdn | SQL Server FQDN |
| dbname | Database name |
| thistagset | Tags applied to resources |

## Notes

- Password is auto-generated and stored in Key Vault
- Uses SQL Server version 12.0
