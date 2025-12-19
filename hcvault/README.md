# HashiCorp Vault Module

This module creates a HashiCorp Vault development instance with Azure Key Vault seal wrap integration.

## Features

- HashiCorp Vault on Ubuntu Linux VM
- Azure Key Vault integration for seal wrap
- StrongDM SSH CA for access
- Managed identity authentication

## Usage

```hcl
module "hcvault" {
  source = "../hcvault"

  name   = "mylab"
  region = "ukwest"
  rg     = "my-resource-group"
  rgid   = azurerm_resource_group.rg.id
  subnet = module.network.relay_subnet
  sshca  = var.ssh_ca_public_key
  akvid  = azurerm_key_vault.sdm.id
  akvdns = azurerm_key_vault.sdm.vault_uri
  tagset = var.tagset
}
```

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| name | Name prefix for resources | string | - |
| region | Azure region | string | - |
| rg | Resource group name | string | null |
| rgid | Resource group ID | string | null |
| subnet | Subnet ID for deployment | string | null |
| tagset | Tags to apply to resources | map(string) | - |
| sshca | StrongDM SSH CA public key | string | - |
| akvid | Azure Key Vault ID | string | - |
| akvdns | Azure Key Vault DNS suffix | string | - |
| target_user | SSH username | string | "sdmadmin" |
| vault_version | Vault version to install | string | "1.18.4" |
| vm_size | VM size | string | "Standard_B1s" |

## Outputs

| Name | Description |
|------|-------------|
| ip | VM private IP address |
| target_user | SSH username |
| tagset | Tags applied to resources |

## Notes

- Development mode instance - not for production use
- Gateway managed identity has full kv/ path privileges
