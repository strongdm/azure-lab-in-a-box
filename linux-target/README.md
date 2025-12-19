# Linux Target Module

This module creates an Ubuntu Linux VM configured with StrongDM SSH CA for certificate-based authentication.

## Features

- Ubuntu 18.04 LTS VM
- StrongDM SSH CA public key configuration
- Private network deployment
- Certificate-based SSH authentication

## Usage

```hcl
module "linux_target" {
  source = "../linux-target"

  name   = "mylab"
  region = "ukwest"
  rg     = "my-resource-group"
  subnet = module.network.relay_subnet
  sshca  = var.ssh_ca_public_key
  tagset = var.tagset
}
```

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| name | Name prefix for resources | string | - |
| region | Azure region | string | - |
| rg | Resource group name | string | - |
| subnet | Subnet ID for deployment | string | null |
| tagset | Tags to apply to resources | map(string) | - |
| sshca | StrongDM SSH CA public key | string | - |
| target_user | SSH username | string | "azureuser" |
| vm_size | VM size | string | "Standard_B1s" |

## Outputs

| Name | Description |
|------|-------------|
| ip | VM private IP address |
| target_user | SSH username |
| tagset | Tags applied to resources |

## Notes

- No public IP - accessible only through StrongDM
- SSH CA configured via cloud-init during provisioning
