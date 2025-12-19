# PostgreSQL Module

This module creates an Azure Database for PostgreSQL Flexible Server for StrongDM access demonstrations.

## Features

- PostgreSQL Flexible Server instance
- Credentials stored in Azure Key Vault
- Firewall rules for StrongDM relay access
- SSL/TLS enforcement

## Usage

```hcl
module "postgresql" {
  source = "../postgresql"

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
| target_user | Database admin username | string | "pgadmin" |
| db_sku | PostgreSQL SKU | string | "B_Standard_B2s" |
| subnet | Subnet ID for VNet integration | string | null |

## Outputs

| Name | Description |
|------|-------------|
| fqdn | PostgreSQL server FQDN |
| thistagset | Tags applied to resources |

## Notes

- Password is auto-generated and stored in Key Vault
- Uses PostgreSQL Flexible Server (latest generation)
