# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Terraform-based "Lab in a Box" solution for deploying StrongDM infrastructure on Azure. It creates a complete demonstration environment with secure access management capabilities, including databases, servers, Kubernetes clusters, and Azure services integration.

## Architecture

The solution follows a modular Terraform structure with:
- **Main Module** (`main/`): Orchestrates all components and contains the primary configuration
- **Component Modules** (`aks/`, `dc/`, `hcvault/`, `network/`, `postgresql/`, etc.): Reusable infrastructure components
- **Public/Private Network Design**: Gateway in public subnet, targets and relay in private subnets
- **StrongDM Integration**: Gateway and relay nodes for secure access management
- **Azure Services**: Managed Identity authentication, Key Vault integration, AKS clusters

## Common Development Commands

### Basic Terraform Operations
```bash
cd main
terraform init
terraform plan
terraform apply
terraform destroy
```

### Configuration
- Copy `terraform.tfvars.example` to `terraform.tfvars` and customize variables
- Set StrongDM API credentials:
  ```bash
  export SDM_API_ACCESS_KEY=auth-aaabbbbcccccc
  export SDM_API_SECRET_KEY=jksafhlksdhfsahgghdslkhaslghasdlkghlasdkhglkshg
  ```

### Validation and Formatting
```bash
terraform fmt --recursive
terraform validate
```

## Key Configuration Variables

### Network Configuration
- `region`: Azure deployment region (default: ukwest)
- `rg`: Existing Resource Group name (creates new if null)
- `vn`: Existing Virtual Network name (creates new if null)
- `gateway_subnet`/`relay_subnet`: Existing subnet IDs (creates new if null)

### Resource Creation Flags
- `create_linux_target`: Linux SSH target with CA authentication
- `create_postgresql`: Azure Database for PostgreSQL
- `create_mssql`: Microsoft SQL Server database
- `create_aks`: Azure Kubernetes Service cluster
- `create_domain_controller`: Windows domain controller
- `create_windows_target`: Windows RDP target
- `create_az_ro`: Azure read-only service principal
- `create_hcvault`: HashiCorp Vault development instance

### Naming and Tagging
- `name`: Resource naming prefix (must be lowercase)
- `tagset`: Tags applied to all StrongDM resources

## Module Structure

### Core Infrastructure Modules
- `network/`: VNet, subnets, security groups, NAT gateway
- `rg/`: Resource group creation
- `gateway.tf`/`relay.tf`: StrongDM infrastructure components

### Target Resource Modules
- `dc/`: Windows Domain Controller with PowerShell provisioning
- `postgresql/`: Azure Database for PostgreSQL with Key Vault integration
- `sqlserver/`: Microsoft SQL Server with Windows authentication
- `aks/`: Azure Kubernetes Service cluster
- `linux-target/`: Linux VMs with SSH CA authentication
- `windowstarget/`: Windows RDP targets with certificate authentication
- `hcvault/`: HashiCorp Vault single-instance development cluster

### Authentication and Access
- `azro/`: Azure read-only service principal for CLI access
- `secretsmgmt/`: Managed secrets for domain user credential rotation
- `akv.tf`: Azure Key Vault integration with managed identity

## Important Development Notes

### Windows Domain Controller Setup
- Domain controller setup requires multiple reboots
- Uses PowerShell scripts with "flag files" (*.done) in C:\ for progress tracking
- Windows target deployment must wait for DC completion

### Security Considerations
- Managed Identity authentication for Azure services
- Service principal passwords expire every 10 days (re-run `terraform apply`)
- SSH CA-based authentication for Linux targets
- Windows certificate authentication integration

### StrongDM Integration
- Gateway registers on public IP with listen address
- Relay provides secure access to private resources
- Resources automatically tagged and organized in StrongDM
- API host configuration supports UK/EU tenants via `SDM_API_HOST`

### Azure-Specific Features
- System-assigned managed identities for secure service authentication
- Azure Key Vault integration for credential storage
- Resource tagging for organization and access control
- Network security groups configured for least-privilege access

## Troubleshooting Tips

1. **Connection Issues**: Verify security group rules allow required ports
2. **Authentication Problems**: Check SDM API credentials and permissions
3. **Windows Setup**: Check C:\ for *.done flag files to track DC setup progress
4. **Terraform State**: State files are gitignored for security
5. **Resource Dependencies**: Some resources have implicit dependencies (DC before Windows target)