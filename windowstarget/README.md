# Windows Target Module for StrongDM Azure Lab

## Overview

This module creates a Windows Server virtual machine that automatically joins an existing Active Directory domain. It serves as a domain-joined Windows target for StrongDM certificate authentication demonstrations, showcasing enterprise Windows environment integration.

## Architecture

The module provisions:
- Windows Server 2019 virtual machine (Standard_DS1_v2 size)
- Network interface in the private subnet
- Automatic domain join process via PowerShell script
- StrongDM RDP CA certificate integration
- Domain user account creation and configuration
- Key Vault integration for credential storage

## Features

- **Automatic Domain Join**: Joins the domain controller created by the DC module
- **Certificate Authentication**: Configured with StrongDM RDP CA for certificate-based access
- **Domain Integration**: Full Active Directory integration with domain users and policies
- **Private Network**: Deployed in private subnet accessible only through StrongDM
- **Secure Credentials**: Local and domain credentials stored in Azure Key Vault

## Use Cases for Partner Training

1. **Domain-Joined Windows Access**: Demonstrate StrongDM's integration with domain-joined Windows servers
2. **Enterprise Authentication**: Show how StrongDM works in typical enterprise Windows environments
3. **RDP Certificate vs. Password**: Compare certificate-based vs. traditional password authentication
4. **Session Recording**: Demonstrate comprehensive RDP session recording and audit capabilities
5. **Group Policy Compliance**: Show how StrongDM works alongside existing Windows Group Policy

## Configuration

### Basic Usage

```hcl
module "windows_target" {
  source              = "../windowstarget"
  region              = var.region
  rg                  = var.rg
  subnet              = var.relay_subnet_id
  tagset              = var.tagset
  name                = var.name
  key_vault_id        = var.key_vault_id
  dc_private_ip       = var.dc_private_ip
  domain_name         = var.domain_name
  domain_admin_user   = var.domain_admin_user
  domain_admin_pass   = var.domain_admin_password
  target_user         = "localadmin"
}
```

### Required Variables

- `region`: Azure region for resource deployment
- `rg`: Resource group name where VM resources will be created
- `subnet`: Subnet ID for VM network interface deployment
- `tagset`: Tags to apply to all resources
- `name`: Name prefix for all resources
- `key_vault_id`: Azure Key Vault ID for credential storage
- `dc_private_ip`: Private IP address of the domain controller
- `domain_name`: Active Directory domain name to join
- `domain_admin_user`: Domain administrator username for join operations
- `domain_admin_pass`: Domain administrator password for join operations
- `target_user`: Local administrator username

## VM Specifications

- **Operating System**: Windows Server 2019
- **VM Size**: Standard_DS1_v2 (1 vCPU, 3.5 GB RAM)
- **Storage**: Standard managed disk
- **Network**: Private IP address in relay subnet
- **Authentication**: RDP certificate-based via StrongDM CA

## Domain Join Process

The domain join is handled by the `join-domain.ps1.tpl` script which:

### Phase 1: Network Configuration
- Sets DNS to point to the domain controller
- Verifies network connectivity to the DC
- Configures Windows networking for domain operations

### Phase 2: Domain Join
- Joins the server to the Active Directory domain
- Uses provided domain administrator credentials
- Configures domain trust relationships

### Phase 3: Post-Join Configuration
- Installs StrongDM RDP CA certificate
- Configures certificate authentication
- Creates local user accounts if needed

## Security Features

1. **Certificate-Based RDP**: Uses StrongDM RDP CA certificates for authentication
2. **Domain Integration**: Full Active Directory authentication and authorization
3. **Private Network**: No public IP address - accessible only through StrongDM
4. **Secure Credentials**: All passwords stored securely in Key Vault
5. **Group Policy Compliance**: Inherits domain security policies

## Dependencies

⚠️ **Critical Dependency**: This module requires the Domain Controller module to be fully deployed and operational before deployment. The domain controller must complete all installation phases.

## Generated Resources

The module creates:
- Azure Windows Virtual Machine
- Network Interface with private IP
- Key Vault secrets for local admin credentials
- Domain join automation scripts

## Outputs

- `vm_name`: Name of the created Windows target VM
- `private_ip`: Private IP address of the VM
- `computer_name`: NetBIOS computer name in the domain
- `domain_joined`: Status of domain join operation
- `key_vault_password_secret`: Key Vault secret name containing local admin password

## Integration with StrongDM

This Windows target is designed to integrate seamlessly with StrongDM for:
- RDP certificate-based authentication
- Session recording and audit logging
- Domain user access control
- Active Directory group-based permissions
- Enterprise Windows compliance scenarios

## Troubleshooting

Common issues and solutions:

1. **Domain Join Failures**: 
   - Verify domain controller is fully operational
   - Check DNS configuration points to DC
   - Ensure domain admin credentials are correct

2. **Network Connectivity**: 
   - Verify VM can reach domain controller IP
   - Check security group rules allow domain traffic
   - Ensure proper subnet configuration

3. **Certificate Issues**: 
   - Verify RDP CA certificate installation
   - Check certificate trust chain
   - Validate StrongDM integration

4. **Authentication Problems**:
   - Confirm domain join completed successfully
   - Verify user accounts exist in domain
   - Check Active Directory trust relationships

## Important Notes

- ⚠️ **Deployment Order**: Domain Controller must be fully configured first
- ⚠️ **Installation Time**: Domain join process can take 5-10 minutes
- ⚠️ **Network Dependencies**: Requires connectivity to domain controller
- ⚠️ **Credential Management**: Uses secure Key Vault storage for all passwords
