# PostgreSQL Module for StrongDM Azure Lab

## Overview

This module creates an Azure Database for PostgreSQL instance that serves as a database target for StrongDM access control demonstrations. It deploys a fully managed PostgreSQL database with secure credential management through Azure Key Vault integration.

## Architecture

The module provisions:
- A PostgreSQL single server instance (Basic tier, Gen5, 1 vCore) 
- Database credentials stored securely in Azure Key Vault
- Firewall rules configured to allow access from StrongDM relay
- SSL/TLS enforcement for secure connections
- Default database administrator account for lab scenarios

## Features

- **Secure Credentials**: Database passwords stored in Azure Key Vault
- **SSL Enforcement**: TLS 1.2 minimum for all connections
- **Firewall Integration**: Configured to allow access from StrongDM relay IP
- **Minimal Resource Footprint**: Basic tier suitable for demo/lab environments
- **Proper Tagging**: Consistent tagging for resource organization

## Use Cases for Partner Training

1. **Database Access Control**: Demonstrate how StrongDM can manage access to PostgreSQL databases
2. **Just-In-Time Database Credentials**: Show temporary database credential issuance through Key Vault integration
3. **Database Activity Monitoring**: Track and audit SQL queries through StrongDM's logging capabilities
4. **Secrets Management Integration**: Illustrate the integration between StrongDM and Azure Key Vault
5. **SSL/TLS Security**: Demonstrate secure database connections with certificate validation

## Configuration

### Basic Usage

```hcl
module "postgresql" {
  source        = "../postgresql"
  region        = var.region
  rg            = var.rg
  tagset        = var.tagset
  name          = var.name
  key_vault_id  = var.key_vault_id
  relay_ip      = var.relay_ip
  target_user   = "pgadmin"
}
```

### Required Variables

- `region`: Azure region for resource deployment
- `rg`: Resource group name where PostgreSQL resources will be created
- `tagset`: Tags to apply to all resources
- `name`: Name prefix for all resources
- `key_vault_id`: Azure Key Vault ID for credential storage
- `relay_ip`: IP address of the StrongDM relay for firewall configuration

### Optional Variables

- `target_user`: Database administrator username (default: "pgadmin")
- `subnet`: Subnet ID for deployment (if using VNet integration)

## Security Considerations

1. **Public Network Access**: Currently enabled for lab scenarios - consider VNet integration for production
2. **Firewall Rules**: Configured to allow specific relay IP addresses only
3. **SSL Enforcement**: All connections require TLS 1.2 or higher
4. **Key Vault Integration**: Database credentials never stored in plaintext in Terraform state

## Database Specifications

- **Version**: PostgreSQL 11
- **Performance Tier**: Basic (B_Gen5_1)
- **Storage**: 5GB (sufficient for lab scenarios)
- **Backup**: Local redundancy (geo-redundancy disabled for cost optimization)
- **Encryption**: Infrastructure encryption available but disabled for lab simplicity

## Outputs

- `server_name`: Name of the created PostgreSQL server
- `server_fqdn`: Fully qualified domain name of the PostgreSQL server
- `database_name`: Name of the default database
- `key_vault_username_secret`: Key Vault secret name containing the database username
- `key_vault_password_secret`: Key Vault secret name containing the database password

## Integration with StrongDM

This PostgreSQL instance is designed to integrate seamlessly with StrongDM for:
- Credential rotation and management
- Session recording and audit logging
- Fine-grained access control policies
- Just-in-time access provisioning
