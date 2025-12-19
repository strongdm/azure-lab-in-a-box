# Main Module for StrongDM Azure Lab

This is the root orchestration module that deploys and configures all lab resources. Run terraform commands from this directory.

## Features

- Orchestrates all Azure lab resources via feature flags
- Configures StrongDM gateway and relay infrastructure
- Manages Azure Key Vault for credential storage
- Supports existing network infrastructure or creates new

## Usage

```hcl
cd main
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| region | Azure region for deployment | string | "ukwest" |
| name | Name prefix for all resources (lowercase) | string | - |
| tagset | Tags to apply to all resources | map(string) | - |
| rg | Existing resource group name (optional) | string | null |
| vn | Existing virtual network name (optional) | string | null |
| gateway_subnet | Existing public subnet ID (optional) | string | null |
| relay_subnet | Existing private subnet ID (optional) | string | null |
| create_aks | Create AKS cluster | bool | false |
| create_postgresql | Create PostgreSQL database | bool | false |
| create_mssql | Create SQL Server database | bool | false |
| create_cosmosdb | Create Cosmos DB (MongoDB API) | bool | false |
| create_domain_controller | Create Windows DC | bool | false |
| create_windows_target | Create Windows RDP target | bool | false |
| create_linux_target | Create Linux SSH target | bool | false |
| create_az_ro | Create Azure read-only service principal | bool | false |
| create_blob_ro | Create Blob Storage read-only access | bool | false |
| create_blob_full | Create Blob Storage full access | bool | false |
| create_datafactory | Create Data Factory access | bool | false |
| create_hcvault | Create HashiCorp Vault instance | bool | false |
| create_managedsecrets | Enable managed secrets for domain users | bool | false |
| vm_sizes | VM sizes for components | object | {} |
| aks_node_size | VM size for AKS nodes | string | "Standard_D2_v3" |
| domain_users | Domain users to create | set(object) | null |

## Notes

- Windows target requires domain controller to be deployed first
- Domain controller setup takes 15-30 minutes with multiple reboots
- Service principal passwords rotate every 10 days
