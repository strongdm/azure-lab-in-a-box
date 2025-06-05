# Network Module for StrongDM Azure Lab

## Overview

This module establishes the foundational network infrastructure for the StrongDM lab environment in Azure. It creates a secure, isolated network environment with properly segmented public and private resources following Azure best practices.

## Architecture

The network consists of:

- **Virtual Network**: A dedicated virtual network with CIDR block 10.0.0.0/16
- **Public Subnet**: Houses internet-facing components like the StrongDM Gateway (10.0.1.0/24)
- **Private Subnet**: Contains protected resources like databases and target servers (10.0.2.0/24)
- **NAT Gateway**: Enables private subnet resources to access the internet while remaining isolated
- **Network Security Groups**: Enforces access control between resources with least-privilege permissions

## Resource Deployment

Resources are deployed into specific subnets based on their security requirements:

| Resource Type | Subnet Type | Justification |
|---------------|------------|---------------|
| StrongDM Gateway | Public | Requires inbound connections from users |
| StrongDM Relay | Private | Only needs outbound access to targets |
| Databases (PostgreSQL, SQL Server) | Private | Protected resources not directly internet accessible |
| Windows/Linux Targets | Private | Protected resources accessed via StrongDM |
| AKS Cluster | Private | Container workloads in protected environment |
| HashiCorp Vault | Private | Secret storage requiring secure access |

## Security Features

The module implements several security best practices:

1. **Network Segmentation**: Clear separation between public-facing and private resources
2. **NAT Gateway**: Allows private resources outbound internet access without exposure
3. **Consistent Tagging**: All resources tagged for proper organization and management
4. **Least-Privilege Design**: Only necessary network paths are created

## Usage in Partner Training

This network setup demonstrates important security principles:

1. **Network Segmentation**: Separating public-facing components from private data
2. **Least-Privilege Access**: Only necessary ports opened for each resource type
3. **Defense-in-Depth**: Multiple security layers protecting sensitive resources
4. **Azure Best Practices**: Following Microsoft's recommended network architecture patterns

## Configuration

### Basic Usage

```hcl
module "network" {
  source  = "../network"
  region  = var.region
  rg      = azurerm_resource_group.rg.name
  tagset  = var.tagset
  name    = var.name
}
```

### Required Variables

- `region`: Azure region for resource deployment
- `rg`: Resource group name where network resources will be created
- `tagset`: Tags to apply to all resources
- `name`: Name prefix for all resources

## Integration with Other Modules

This module outputs subnet IDs, virtual network information, and resource group details that other modules reference when creating their resources, ensuring consistent networking configuration throughout the lab environment.

## Outputs

- `gateway_subnet_id`: ID of the public subnet for gateway deployment
- `relay_subnet_id`: ID of the private subnet for relay and target deployment
- `virtual_network_id`: ID of the created virtual network
- `resource_group_name`: Name of the resource group containing network resources
