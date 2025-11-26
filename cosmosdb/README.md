# Azure Cosmos DB Module (MongoDB API)

This module creates an Azure Cosmos DB account with MongoDB API compatibility, equivalent to AWS DocumentDB. It provides a MongoDB-compatible database service that can be managed through StrongDM.

## Features

- Azure Cosmos DB account with MongoDB API
- Serverless capacity mode for cost-efficient lab environments
- Firewall rules for secure access from StrongDM relay
- Credentials stored in Azure Key Vault
- Session consistency level

## Usage

```hcl
module "cosmosdb" {
  source = "../cosmosdb"

  name         = "mylab"
  region       = "ukwest"
  rg           = "my-resource-group"
  relay_ip     = "10.0.0.5"
  key_vault_id = azurerm_key_vault.sdm.id
  tagset       = var.tagset
}
```

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| name | Arbitrary string to add to resources | string | - |
| region | Azure Region to create resources on | string | - |
| rg | Resource group name | string | - |
| relay_ip | Relay IP to allow through firewall | string | null |
| key_vault_id | Key Vault ID for storing secrets | string | null |
| username | Username for Cosmos DB | string | "cosmosadmin" |
| throughput | Database throughput in RU/s | number | 400 |
| db_name | Name of the MongoDB database | string | "labdb" |
| tagset | Tags to apply to resources | map(string) | - |

## Outputs

| Name | Description |
|------|-------------|
| endpoint | Cosmos DB account endpoint |
| hostname | MongoDB connection hostname |
| port | MongoDB connection port (10255) |
| account_name | Account name (used as username) |
| primary_key | Primary key (used as password) |
| database_name | Name of the MongoDB database |
| thistagset | Tags applied to resources |
| account_id | Cosmos DB account ID |

## Notes

- Cosmos DB with MongoDB API uses port 10255 (not the standard MongoDB port 27017)
- The account name is used as the username for authentication
- The primary key is used as the password for authentication
- Serverless mode is used for cost efficiency; consider provisioned throughput for production
