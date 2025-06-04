# Linux Target Module for StrongDM Azure Lab

## Overview

This module creates an Ubuntu Linux virtual machine that serves as an SSH target for StrongDM certificate authentication demonstrations. It provisions a minimal Linux VM configured with the StrongDM SSH Certificate Authority (CA) public key, enabling secure certificate-based SSH access.

## Architecture

The module provisions:
- Ubuntu 18.04 LTS virtual machine (Standard_B1s size)
- Network interface in the private subnet
- StrongDM SSH CA public key configuration
- Custom provisioning script for CA setup
- Generated SSH key pair for initial VM access

## Features

- **Certificate Authentication**: Configured with StrongDM SSH CA for certificate-based access
- **Minimal Footprint**: Uses Standard_B1s VM size suitable for demo scenarios
- **Private Network**: Deployed in private subnet accessible only through StrongDM
- **Cloud-Init Integration**: Automated CA configuration during VM provisioning
- **Secure Access**: No direct SSH access - all access routed through StrongDM

## Use Cases for Partner Training

1. **SSH Certificate Authentication**: Demonstrate StrongDM's SSH CA capabilities
2. **Certificate vs. Key Authentication**: Compare traditional SSH keys with certificate-based access
3. **Zero Trust Access**: Show how users access servers without direct network connectivity
4. **Session Recording**: Illustrate SSH session recording and audit capabilities
5. **Just-in-Time Access**: Demonstrate temporary certificate issuance for specific time periods

## Configuration

### Basic Usage

```hcl
module "linux_target" {
  source       = "../linux-target"
  region       = var.region
  rg           = var.rg
  subnet       = var.relay_subnet_id
  tagset       = var.tagset
  name         = var.name
  sshca        = var.ssh_ca_public_key
  target_user  = "ubuntu"
}
```

### Required Variables

- `region`: Azure region for resource deployment
- `rg`: Resource group name where VM resources will be created
- `subnet`: Subnet ID for VM network interface deployment
- `tagset`: Tags to apply to all resources
- `name`: Name prefix for all resources
- `sshca`: StrongDM SSH CA public key for certificate authentication
- `target_user`: Username for SSH access (default: "ubuntu")

## VM Specifications

- **Operating System**: Ubuntu 18.04 LTS
- **VM Size**: Standard_B1s (1 vCPU, 1 GB RAM)
- **Storage**: Standard managed disk
- **Network**: Private IP address in relay subnet
- **Authentication**: SSH certificate-based via StrongDM CA

## Security Features

1. **Certificate-Only Access**: Configured to accept only SSH certificate authentication
2. **Private Network**: No public IP address - accessible only through StrongDM
3. **Minimal Attack Surface**: Basic Ubuntu installation with minimal packages
4. **Secure Provisioning**: Cloud-init script securely configures SSH CA

## Certificate Authority Setup

The provisioning script (`ca-provision.tpl`) performs:
1. Installation of StrongDM SSH CA public key
2. Configuration of SSH daemon to trust the CA
3. Setup of certificate principals and validation
4. Creation of appropriate user accounts and permissions

## Generated Resources

The module creates:
- Azure Linux Virtual Machine
- Network Interface with private IP
- SSH key pair for initial access (stored securely)
- Custom provisioning script execution

## Outputs

- `vm_name`: Name of the created Linux VM
- `private_ip`: Private IP address of the VM
- `network_interface_id`: ID of the VM's network interface
- `vm_id`: Azure resource ID of the virtual machine

## Integration with StrongDM

This Linux target is designed to integrate seamlessly with StrongDM for:
- SSH certificate-based authentication
- Session recording and audit logging
- Fine-grained access control policies
- Temporary certificate issuance for just-in-time access
- User activity monitoring and compliance reporting

## Troubleshooting

Common issues and solutions:

1. **Certificate Authentication Failures**: Verify SSH CA public key is correctly configured
2. **Network Connectivity**: Ensure VM is in the correct private subnet
3. **Provisioning Issues**: Check cloud-init logs on the VM for script execution errors
4. **StrongDM Integration**: Verify the target is properly registered in StrongDM with correct credentials
