# Domain Controller Module for StrongDM Azure Lab

## Overview

This module creates a Windows Server virtual machine configured as an Active Directory Domain Controller. It serves as the foundation for Windows-based authentication demonstrations in the StrongDM lab environment, enabling certificate-based RDP access and domain authentication scenarios.

## Architecture

The module provisions:
- Windows Server 2019 virtual machine (Standard_DS1_v2 size)
- Network interface in the private subnet
- Active Directory Domain Services installation and configuration
- StrongDM RDP CA certificate integration
- Automated domain controller promotion script
- Key Vault integration for credential storage

## Features

- **Automated AD Setup**: Complete Active Directory forest installation via PowerShell script
- **Certificate Authentication**: Configured with StrongDM RDP CA for certificate-based access
- **Private Network**: Deployed in private subnet accessible only through StrongDM
- **Secure Credentials**: Domain administrator credentials stored in Azure Key Vault
- **Multi-Reboot Process**: Handles the complex domain controller installation process automatically

## Use Cases for Partner Training

1. **Windows Domain Authentication**: Demonstrate StrongDM's integration with Active Directory
2. **RDP Certificate Authentication**: Show certificate-based RDP access vs. password authentication
3. **Domain Services**: Illustrate how StrongDM works with enterprise Windows environments
4. **Session Recording**: Demonstrate RDP session recording and audit capabilities
5. **Group Policy Integration**: Show how StrongDM can work alongside existing Windows policies

## Configuration

### Basic Usage

```hcl
module "domain_controller" {
  source        = "../dc"
  region        = var.region
  rg            = var.rg
  subnet        = var.relay_subnet_id
  tagset        = var.tagset
  name          = var.name
  key_vault_id  = var.key_vault_id
  target_user   = "Administrator"
}
```

### Required Variables

- `region`: Azure region for resource deployment
- `rg`: Resource group name where VM resources will be created
- `subnet`: Subnet ID for VM network interface deployment
- `tagset`: Tags to apply to all resources
- `name`: Name prefix for all resources
- `key_vault_id`: Azure Key Vault ID for credential storage
- `target_user`: Domain administrator username (default: "Administrator")

## VM Specifications

- **Operating System**: Windows Server 2019
- **VM Size**: Standard_DS1_v2 (1 vCPU, 3.5 GB RAM)
- **Storage**: Premium managed disk
- **Network**: Private IP address in relay subnet
- **Authentication**: RDP certificate-based via StrongDM CA

## Installation Process

The domain controller setup is a multi-phase process managed by the `install-dc.ps1.tpl` script:

### Phase 1: Initial Setup
- Configure Windows features and roles
- Install Active Directory Domain Services role
- Set up initial network configuration

### Phase 2: Domain Creation
- Promote server to domain controller
- Create new Active Directory forest
- Configure DNS services

### Phase 3: Post-Installation
- Install StrongDM RDP CA certificate
- Configure certificate authentication
- Create completion flag files

### Monitoring Progress
The script creates flag files in C:\ to track progress:
- `first-logon.done`: Initial setup complete
- `second-logon.done`: Domain promotion complete
- `third-logon.done`: Full installation complete

## Security Features

1. **Certificate-Only RDP**: Configured to use StrongDM RDP CA certificates
2. **Private Network**: No public IP address - accessible only through StrongDM
3. **Secure Credentials**: Domain admin password stored in Key Vault
4. **Domain Security**: Standard Active Directory security policies applied

## Generated Resources

The module creates:
- Azure Windows Virtual Machine
- Network Interface with private IP
- Key Vault secrets for domain credentials
- Domain controller promotion scripts

## Outputs

- `vm_name`: Name of the created domain controller VM
- `private_ip`: Private IP address of the VM
- `domain_name`: Name of the created Active Directory domain
- `admin_username`: Domain administrator username
- `key_vault_password_secret`: Key Vault secret name containing admin password

## Integration with StrongDM

This domain controller is designed to integrate seamlessly with StrongDM for:
- RDP certificate-based authentication
- Session recording and audit logging
- Active Directory user and group synchronization
- Domain-joined Windows target management
- Enterprise Windows authentication scenarios

## Dependencies

This module should be deployed before any Windows targets that need to join the domain. The domain controller must be fully configured before attempting to deploy the Windows target module.

## Troubleshooting

Common issues and solutions:

1. **Installation Stalled**: Check C:\ for flag files to determine current phase
2. **Domain Services Issues**: Review Windows Event Logs on the VM
3. **Certificate Problems**: Verify RDP CA certificate installation
4. **Network Connectivity**: Ensure VM is in the correct private subnet and can reach Azure services
5. **Reboot Issues**: The installation requires multiple reboots - wait for each phase to complete

## Important Notes

- ⚠️ **Installation Time**: Complete domain controller setup can take 15-30 minutes
- ⚠️ **Dependency Order**: Must be deployed before Windows targets
- ⚠️ **Reboot Cycles**: The VM will reboot multiple times during installation
- ⚠️ **Monitoring**: Use the flag files in C:\ to monitor installation progress
