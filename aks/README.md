# AKS Module

This module creates an Azure Kubernetes Service (AKS) cluster for container orchestration demonstrations with StrongDM.

## Features

- AKS cluster with system-assigned managed identity
- SSH key authentication for Linux nodes
- Cluster credentials stored in Azure Key Vault
- Kubenet networking with standard load balancer

## Usage

```hcl
module "aks" {
  source = "../aks"

  name         = "mylab"
  region       = "ukwest"
  rg           = "my-resource-group"
  tagset       = var.tagset
  key_vault_id = azurerm_key_vault.sdm.id
}
```

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| name | Name prefix for resources | string | - |
| region | Azure region | string | - |
| rg | Resource group name | string | - |
| tagset | Tags to apply to resources | map(string) | - |
| key_vault_id | Key Vault ID for storing credentials | string | null |
| target_user | Linux admin username | string | "k8sadmin" |
| node_vm_size | VM size for AKS nodes | string | "Standard_D2_v3" |

## Outputs

| Name | Description |
|------|-------------|
| fqdn | AKS cluster FQDN |
| name | AKS cluster name |
| thistagset | Tags applied to resources |

## Notes

- Sample Kubernetes manifests available in `aks-sample-app` directory
- Cluster uses 2 nodes by default
