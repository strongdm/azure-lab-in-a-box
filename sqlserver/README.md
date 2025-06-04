# SQL Server Module for StrongDM Azure Lab

## Overview

This module creates a Microsoft SQL Server (Azure SQL Database) instance that serves as a database target for StrongDM access control demonstrations. It deploys a fully managed SQL Server database with secure credential management through Azure Key Vault integration.

## Architecture

The module provisions:
- Azure SQL Database server (version 12.0)
- Database instance with configurable name
- Database credentials stored securely in Azure Key Vault
- Firewall rules configured to allow access from StrongDM relay
- Server-level administrator account for lab scenarios

## Features

- **Managed SQL Server**: Fully managed Azure SQL Database service
- **Secure Credentials**: Database passwords stored in Azure Key Vault
- **Firewall Integration**: Configured to allow access from StrongDM relay IP
- **Flexible Database Naming**: Configurable database name for different scenarios
- **Enterprise-Grade**: Production-ready SQL Server features in lab environment
- **Proper Tagging**: Consistent tagging for resource organization

## Use Cases for Partner Training

1. **SQL Server Access Control**: Demonstrate how StrongDM can manage access to SQL Server databases
2. **Enterprise Database Integration**: Show StrongDM's capabilities with Microsoft SQL Server environments
3. **Just-In-Time Database Credentials**: Illustrate temporary credential issuance through Key Vault integration
4. **Database Activity Monitoring**: Track and audit T-SQL queries through StrongDM's logging capabilities
5. **Windows Authentication Integration**: Demonstrate SQL Server authentication alongside Active Directory

## Configuration

### Basic Usage

```hcl
module "sql_server" {
  source        = "../sqlserver"
  region        = var.region
  rg            = var.rg
  tagset        = var.tagset
  name          = var.name
  key_vault_id  = var.key_vault_id
  relay_ip      = var.relay_ip
  target_user   = "sqladmin"
  dbname        = "SampleDB"
}
```

### Required Variables

- `region`: Azure region for resource deployment
- `rg`: Resource group name where SQL Server resources will be created
- `tagset`: Tags to apply to all resources
- `name`: Name prefix for all resources
- `key_vault_id`: Azure Key Vault ID for credential storage
- `relay_ip`: IP address of the StrongDM relay for firewall configuration

### Optional Variables

- `target_user`: Database administrator username (default: "sqladmin")
- `dbname`: Name of the database to create (default: "SampleDB")

## Database Specifications

- **Version**: SQL Server 12.0 (SQL Server 2014 compatibility level)
- **Service Tier**: Standard (suitable for lab scenarios)
- **Performance**: DTU-based pricing model
- **Backup**: Automated backup with point-in-time restore capability
- **Security**: TLS encryption in transit, Azure security features enabled

## Security Considerations

1. **Public Network Access**: Currently enabled for lab scenarios - consider VNet integration for production
2. **Firewall Rules**: Configured to allow specific relay IP addresses only
3. **TLS Encryption**: All connections encrypted in transit
4. **Key Vault Integration**: Database credentials never stored in plaintext in Terraform state
5. **Azure Security**: Leverages Azure's built-in security features and compliance

## SQL Server Features

The deployed SQL Server includes:
- **T-SQL Support**: Full Transact-SQL compatibility
- **Stored Procedures**: Support for stored procedures and functions
- **Views and Triggers**: Complete database object support
- **Security Features**: Row-level security, dynamic data masking capabilities
- **Performance Tools**: Query performance insights and recommendations

## Generated Resources

The module creates:
- Azure SQL Database server
- Database instance within the server
- Firewall rule for StrongDM relay access
- Key Vault secrets for database credentials

## Outputs

- `server_name`: Name of the created SQL Server
- `server_fqdn`: Fully qualified domain name of the SQL Server
- `database_name`: Name of the created database
- `key_vault_username_secret`: Key Vault secret name containing the database username
- `key_vault_password_secret`: Key Vault secret name containing the database password

## Integration with StrongDM

This SQL Server instance is designed to integrate seamlessly with StrongDM for:
- SQL Server Management Studio (SSMS) access through StrongDM
- T-SQL query execution and monitoring
- Credential rotation and management
- Session recording and audit logging
- Fine-grained access control policies
- Just-in-time access provisioning

## Sample T-SQL Operations

Once configured in StrongDM, users can perform operations like:

```sql
-- Database exploration
SELECT name FROM sys.databases;
USE SampleDB;

-- Table operations
CREATE TABLE Users (
    ID int IDENTITY(1,1) PRIMARY KEY,
    Username NVARCHAR(50),
    Email NVARCHAR(100),
    CreatedDate DATETIME DEFAULT GETDATE()
);

-- Data manipulation
INSERT INTO Users (Username, Email) VALUES ('testuser', 'test@example.com');
SELECT * FROM Users;

-- Administrative queries
SELECT @@VERSION;
SELECT name, database_id, create_date FROM sys.databases;
```

## Troubleshooting

Common issues and solutions:

1. **Connection Failures**:
   - Verify firewall rules allow access from StrongDM relay IP
   - Check Azure SQL Database service status
   - Ensure correct server FQDN is being used

2. **Authentication Issues**:
   - Confirm database administrator credentials in Key Vault
   - Verify SQL authentication is enabled on the server
   - Check for any Azure AD authentication conflicts

3. **Performance Issues**:
   - Monitor DTU consumption in Azure portal
   - Consider upgrading service tier for better performance
   - Review query performance recommendations

4. **Network Connectivity**:
   - Verify StrongDM relay can reach Azure SQL Database endpoints
   - Check DNS resolution for server FQDN
   - Ensure no network security groups blocking traffic

## Important Notes

- ⚠️ **Public Access**: Database is accessible from internet with proper authentication
- ⚠️ **Firewall Rules**: Only StrongDM relay IP is allowed by default
- ⚠️ **Credential Storage**: All passwords securely stored in Azure Key Vault
- ⚠️ **Backup Policy**: Default Azure backup policy applies - review for production use
