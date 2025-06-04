# Azure Read-Only Module for StrongDM Azure Lab

## Overview

This module creates an Azure service principal with read-only permissions to Azure resources. It demonstrates how StrongDM can manage access to cloud provider APIs and CLI tools, enabling secure Azure resource browsing and monitoring without modification capabilities.

## Architecture

The module provisions:
- Azure AD application registration
- Service principal with Reader role assignment
- Auto-rotating password (every 10 days)
- StrongDM CLI target configuration for Azure CLI access
- Secure credential storage in Azure Key Vault

## Features

- **Read-Only Access**: Service principal has only Reader permissions across the subscription
- **Auto-Rotating Credentials**: Password automatically rotates every 10 days for security
- **CLI Integration**: Pre-configured for Azure CLI access through StrongDM
- **Secure Storage**: Credentials stored in Azure Key Vault
- **Subscription-Wide Access**: Can read resources across the entire Azure subscription

## Use Cases for Partner Training

1. **Cloud API Access Control**: Demonstrate how StrongDM manages access to cloud provider APIs
2. **CLI Tool Integration**: Show secure access to Azure CLI and Azure PowerShell
3. **Read-Only Compliance**: Illustrate controlled access for audit and monitoring scenarios
4. **Credential Rotation**: Demonstrate automatic credential rotation capabilities
5. **Multi-Cloud Access**: Show consistent access patterns across different cloud providers

## Configuration

### Basic Usage

```hcl
module "azure_readonly" {
  source        = "../azro"
  name          = var.name
  tagset        = var.tagset
  key_vault_id  = var.key_vault_id
}
```

### Required Variables

- `name`: Name prefix for all resources
- `tagset`: Tags to apply to all resources
- `key_vault_id`: Azure Key Vault ID for credential storage

## Service Principal Specifications

- **Display Name**: `{name}-SDM-ReadOnly`
- **Role Assignment**: Reader (read-only access to all resources)
- **Scope**: Subscription-level access
- **Credential Rotation**: Every 10 days
- **Authentication**: Client ID and secret

## Permissions Granted

The service principal has Reader role permissions, which include:
- View all Azure resources in the subscription
- Read resource configurations and properties
- Access to Azure Resource Manager APIs (read-only)
- View billing and usage information
- Read Azure Active Directory objects (limited)

**Important**: The service principal cannot:
- Create, modify, or delete any resources
- Change permissions or role assignments
- Access sensitive data stored within resources (like VM file systems)

## Security Features

1. **Least Privilege**: Only Reader permissions granted
2. **Auto-Rotation**: Credentials automatically rotate every 10 days
3. **Secure Storage**: Client secret stored in Azure Key Vault
4. **Audit Trail**: All access logged through StrongDM
5. **Time-Limited Access**: StrongDM can provide just-in-time access to CLI sessions

## Generated Resources

The module creates:
- Azure AD Application
- Service Principal
- Role Assignment (Reader)
- Time-based rotation schedule
- Key Vault secrets for credentials

## Outputs

- `application_id`: Azure AD application (client) ID
- `service_principal_id`: Service principal object ID
- `tenant_id`: Azure tenant ID
- `key_vault_secret_name`: Key Vault secret containing the client secret

## Integration with StrongDM

This Azure Read-Only access is designed to integrate with StrongDM for:
- Secure Azure CLI access through StrongDM gateway
- Session recording of CLI commands and API calls
- Just-in-time access to Azure resources
- Audit logging of all Azure resource queries
- Fine-grained access control to specific Azure services

## Azure CLI Usage

Once configured in StrongDM, users can access Azure CLI with commands like:

```bash
# Login using the service principal (handled automatically by StrongDM)
az login --service-principal -u <client-id> -p <client-secret> --tenant <tenant-id>

# Example read-only operations
az group list
az vm list
az storage account list
az network vnet list
```

## Credential Rotation

The module implements automatic credential rotation:
- **Rotation Period**: 10 days
- **Automatic Update**: New credentials automatically stored in Key Vault
- **StrongDM Sync**: StrongDM target automatically updated with new credentials
- **Zero Downtime**: Rotation happens seamlessly without service interruption

## Troubleshooting

Common issues and solutions:

1. **Authentication Failures**: 
   - Verify service principal has Reader role assigned
   - Check credential rotation hasn't created temporary conflicts
   - Ensure Azure AD application is properly configured

2. **Permission Denied**: 
   - Confirm Reader role is assigned at subscription level
   - Verify the service principal is active and not disabled

3. **Credential Rotation Issues**:
   - Check Key Vault access permissions
   - Verify time rotation schedule is configured correctly
   - Ensure StrongDM can access updated credentials

4. **CLI Access Problems**:
   - Verify StrongDM target is configured correctly
   - Check Azure CLI is properly configured in the StrongDM session
   - Ensure network connectivity to Azure APIs

## Important Notes

- ⚠️ **Read-Only Limitation**: This service principal cannot modify any Azure resources
- ⚠️ **Credential Rotation**: Passwords change every 10 days - ensure StrongDM stays synchronized
- ⚠️ **Subscription Scope**: Has access to read all resources in the subscription
- ⚠️ **API Rate Limits**: Azure API rate limits apply to all operations
