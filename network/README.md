# Network Module

This module creates the network infrastructure for the StrongDM Azure lab environment.

## Features

- Virtual network with configurable address space
- Public subnet for StrongDM gateway
- Private subnet for relay and targets
- NAT gateway for private subnet internet access
- Network security groups

## Usage

```hcl
module "network" {
  source = "../network"

  name   = "mylab"
  region = "ukwest"
  rg     = "my-resource-group"
  tagset = var.tagset
}
```

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| name | Name prefix for resources | string | - |
| region | Azure region | string | - |
| rg | Resource group name | string | null |
| tagset | Tags to apply to resources | map(string) | - |
| vnet_address_space | VNet address space | list(string) | ["10.0.0.0/16"] |
| gateway_subnet_prefix | Gateway subnet CIDR | string | "10.0.1.0/24" |
| relay_subnet_prefix | Relay subnet CIDR | string | "10.0.2.0/24" |
| allowed_ssh_cidr_blocks | CIDR blocks allowed for SSH | list(string) | ["0.0.0.0/0"] |
| strongdm_port | StrongDM gateway port | number | 5000 |

## Outputs

| Name | Description |
|------|-------------|
| gateway_subnet | Public subnet ID |
| relay_subnet | Private subnet ID |
| vnid | Virtual network ID |
| vnname | Virtual network name |
| natip | NAT gateway public IP |
