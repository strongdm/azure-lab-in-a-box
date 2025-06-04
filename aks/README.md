# AKS Module for StrongDM Azure Lab

## Overview

This module creates an Azure Kubernetes Service (AKS) cluster that serves as a container orchestration target for StrongDM access control demonstrations. It deploys a fully managed Kubernetes cluster with secure authentication and credential management through Azure Key Vault integration.

## Architecture

The module provisions:
- An AKS cluster with system-assigned managed identity
- Default node pool with 2 Standard_D2_v2 virtual machines
- SSH key-based authentication for Linux nodes
- Network configuration with kubenet plugin and standard load balancer
- Cluster credentials stored securely in Azure Key Vault
- Generated SSH key pair for node access

## Features

- **Managed Identity**: System-assigned identity for secure Azure service integration
- **SSH Key Authentication**: Generated SSH key pair for secure node access
- **Standard Networking**: Kubenet plugin with standard load balancer configuration
- **Multi-Node Setup**: 2-node cluster suitable for demo scenarios
- **Key Vault Integration**: Cluster credentials and SSH keys stored securely
- **Proper Tagging**: Consistent tagging for resource organization

## Use Cases for Partner Training

1. **Kubernetes Access Control**: Demonstrate how StrongDM can manage access to Kubernetes clusters
2. **Container Workload Security**: Show secure access to containerized applications
3. **Multi-Protocol Support**: Illustrate kubectl access alongside other resources
4. **Modern Infrastructure**: Demonstrate StrongDM's cloud-native capabilities
5. **DevOps Integration**: Show how StrongDM fits into modern development workflows

## Configuration

### Basic Usage

```hcl
module "aks" {
  source        = "../aks"
  region        = var.region
  rg            = var.rg
  tagset        = var.tagset
  name          = var.name
  key_vault_id  = var.key_vault_id
  target_user   = "azureuser"
}
```

### Required Variables

- `region`: Azure region for resource deployment
- `rg`: Resource group name where AKS resources will be created
- `tagset`: Tags to apply to all resources
- `name`: Name prefix for all resources
- `key_vault_id`: Azure Key Vault ID for credential storage

### Optional Variables

- `target_user`: Linux admin username for cluster nodes (default: "azureuser")

## Cluster Specifications

- **Kubernetes Version**: Latest supported AKS version
- **Node Pool**: Default agent pool with 2 nodes
- **VM Size**: Standard_D2_v2 (2 vCPUs, 7 GB RAM)
- **Network Plugin**: kubenet (basic networking)
- **Load Balancer**: Standard SKU
- **Identity**: System-assigned managed identity

## Security Features

1. **SSH Key Authentication**: Generated SSH key pair for secure node access
2. **Managed Identity**: No stored credentials for Azure service authentication
3. **Key Vault Storage**: Sensitive credentials stored securely in Key Vault
4. **Network Isolation**: Cluster deployed in private subnet when integrated with network module

## Generated Resources

The module creates:
- AKS cluster with specified configuration
- SSH key pair (private key stored in Key Vault)
- System-assigned managed identity
- Default node pool with specified VM size and count

## Outputs

- `cluster_name`: Name of the created AKS cluster
- `kube_config`: Kubernetes configuration for cluster access
- `cluster_ca_certificate`: Cluster CA certificate for secure communication
- `cluster_endpoint`: Kubernetes API server endpoint
- `ssh_private_key_secret`: Key Vault secret name containing SSH private key

## Integration with StrongDM

This AKS cluster is designed to integrate seamlessly with StrongDM for:
- Kubectl command authentication and authorization
- Session recording and audit logging of Kubernetes operations
- Fine-grained RBAC policy enforcement
- Temporary kubeconfig generation for just-in-time access

## Sample Applications

The lab includes sample Kubernetes manifests in the `aks-sample-app` directory to demonstrate:
- Pod deployment and management
- Service creation and networking
- StrongDM access to running containers
- Kubernetes resource monitoring through StrongDM
