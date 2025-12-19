# Azure Cosmos DB Module (MongoDB API)

This module creates an Azure Cosmos DB account with MongoDB API compatibility for StrongDM access demonstrations.

## Features

- Cosmos DB account with MongoDB API
- Serverless capacity mode
- Firewall rules for StrongDM relay access
- Credentials stored in Azure Key Vault

## Usage

```hcl
module "cosmosdb" {
  source = "../cosmosdb"

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
| rg | Resource group name | string | - |
| tagset | Tags to apply to resources | map(string) | - |
| relay_ip | Relay IP for firewall rules | string | null |
| key_vault_id | Key Vault ID for credentials | string | null |
| username | Username for Cosmos DB | string | "cosmosadmin" |
| throughput | Database throughput (RU/s) | number | 400 |
| db_name | MongoDB database name | string | "labdb" |

## Outputs

| Name | Description |
|------|-------------|
| endpoint | Cosmos DB account endpoint |
| hostname | MongoDB connection hostname |
| port | MongoDB connection port (10255) |
| account_name | Account name (used as username) |
| primary_key | Primary key (used as password) |
| database_name | MongoDB database name |
| thistagset | Tags applied to resources |
| account_id | Cosmos DB account ID |

## Notes

- Uses port 10255 (not standard MongoDB port 27017)
- Account name is used as username, primary key as password
