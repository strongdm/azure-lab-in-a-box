# StrongDM Lab in a Box for Azure

> [!Warning]
> While we will attempt to keep tagged versions "working", there are a lot of improvements being shipped.
> Update with caution :)

## Overview

This repository contains a set of modules that enable the user to deploy a quick lab environment to evaluate StrongDM capabilities. The infrastructure is fully automated using Terraform and can be deployed in your Azure subscription in minutes.

### Included Resources

- **Network Infrastructure**: Resource Group, Virtual Network, subnets, security groups, NAT and Internet Gateway
- **StrongDM Infrastructure**: Gateway and relay with Azure Key Vault integration using managed identity
- **Database Targets**:
  - Azure Database for PostgreSQL with credentials in Azure Key Vault
  - Microsoft SQL Server with Windows authentication
- **Windows Resources**:
  - Windows domain controller
  - Windows server target with certificate authentication
- **Linux Resources**: SSH target using StrongDM's CA for authentication
- **Kubernetes**: AKS Cluster for container workloads
- **Azure Access**: Read-only access to Azure resources via CLI
- **HashiCorp Vault**: Single instance development cluster with managed identity authentication

All resources are properly tagged according to variables set in the module, ensuring consistent resource management and appropriate access roles in StrongDM.

## Architecture

The lab environment creates a secure network architecture with:
- Public subnet for internet-facing components (StrongDM gateway)
- Private subnets for protected resources (databases, servers)
- Security groups configured for least-privilege access
- Proper routing between public and private resources
- Managed identity integration for secure Azure service authentication

## Prerequisites

In addition to the usual access credentials for Azure, the modules require an access key to StrongDM with the following privileges:

The API token requires the following permissions:

**Secret Store Management:**
- `secretstore:list`, `secretstore:create`, `secretstore:update`, `secretstore:delete`

**Infrastructure Management:**
- `organization:view_settings`
- `relay:list`, `relay:create`
- `policy:read`, `policy:write`

**Resource Management:**
- `datasource:list`, `datasource:create`, `datasource:update`, `datasource:delete`, `datasource:healthcheck`
- `resourcelock:delete`, `resourcelock:list`
- `accessrequest:requester`

**Secret Engine & Managed Secrets:**
- `secretengine:create`, `secretengine:list`, `secretengine:delete`, `secretengine:update`
- `managedsecret:list`, `managedsecret:update`, `managedsecret:create`, `managedsecret:read`, `managedsecret:delete`

You can create the token with the following command:

```bash
sdm admin tokens add TerraformSecMgmt --permissions secretstore:list,secretstore:create,secretstore:update,secretstore:delete,organization:view_settings,relay:list,relay:create,policy:read,policy:write,datasource:list,datasource:create,datasource:update,datasource:delete,datasource:healthcheck,resourcelock:delete,resourcelock:list,accessrequest:requester,secretengine:create,secretengine:list,secretengine:delete,secretengine:update,managedsecret:list,managedsecret:update,managedsecret:create,managedsecret:read,managedsecret:delete --duration 648000 --type api
```

Export the environment variables:

```bash
export SDM_API_ACCESS_KEY=auth-aaabbbbcccccc
export SDM_API_SECRET_KEY=jksafhlksdhfsahgghdslkhaslghasdlkghlasdkhglkshg
```
or in Powershell:
```powershell
$env:SDM_API_ACCESS_KEY="auth-xxxxxx888x8x88x8x6"
$env:SDM_API_SECRET_KEY="X4fasfasfasfasfasfsafaaqED34ge5343CkQ"
```

> [!IMPORTANT]
> **SDM_API_HOST Configuration**
>
> If your control plane is in the UK or EU region, you **must** set the `SDM_API_HOST` environment variable.
> Gateways and relays will use this variable to register against the correct tenant.
>
> **Required Format**: `hostname:port` (e.g., `api.uk.strongdm.com:443`)
>
> **Important**:
> - **DO NOT** include `http://` or `https://` prefix
> - **DO** include the port number (typically `:443`)
> - Common values:
>   - US: `api.strongdm.com:443` (or `app.strongdm.com:443`)
>   - EU: `api.eu.strongdm.com:443`
>   - UK: `api.uk.strongdm.com:443`

```bash
export SDM_API_HOST=api.uk.strongdm.com:443
```
or in Powershell:
```powershell
$env:SDM_API_HOST="api.uk.strongdm.com:443"
```

> [!NOTE]
> The verification of the operating system is done based on the presence of "c:" in the module path. If there is no c:,
> the module will not assume you're using Windows.

Make sure you're logged into sdm with:
```bash
sdm login
```
This is important if you're using the Windows CA target, as it will use the local process to pull the Windows CA Certificate.

## Configuration Variables

### Network Configuration
- `region`: Azure region where resources will be deployed (default: ukwest).
- `rg`: Name of an existing Resource Group. If null, a new Resource Group will be created.
- `vn`: Name of an existing Virtual Network. If null, a new Virtual Network will be created.
- `gateway_subnet`: ID of a public subnet for the StrongDM Gateway.
- `relay_subnet`: Private subnet to deploy resources and targets.

> The module will not verify if the right network configuration is set, so make sure to refer to the SDM [Ports Guide](https://www.strongdm.com/docs/admin/deployment/ports-guide/)

### Resource Flags
- `create_linux_target`: Create a Linux target with SSH CA authentication.
- `create_postgresql`: Create an Azure Database for PostgreSQL.
- `create_mssql`: Create a Microsoft SQL Server database.
- `create_aks`: Create an Azure Kubernetes Service (AKS) cluster.
- `create_domain_controller`: Create a Windows domain controller.
- `create_windows_target`: Create a Windows RDP target.
- `create_az_ro`: Create a service principal for read-only Azure access.
- `create_hcvault`: Deploy a single instance HashiCorp Vault cluster.

### General Configuration
- `tagset`: Tags to apply to all resources.
- `name`: An arbitrary string that will be added to all resource names (must be lowercase).

You can reference the [terraform.tfvars.example](main/terraform.tfvars.example) file in the main module for example configurations.

## Getting Started

Within the main module, do the usual steps:

```bash
cd main
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
``` 

If you're running this in Windows, you may have to set your execution policy accordingly as the script will run local PowerShell commands to retrieve the CA certificate:

```powershell
Set-ExecutionPolicy Bypass
```

## Windows Target Considerations

Setting up a domain controller takes several reboots. This is implemented by a persistent PowerShell script that runs at each reboot and has flow control through creating some "flag files" in C:\ with the "done" extension as each step is completed. You can reference the full PowerShell script [here](dc/install-dc.ps1.tpl).

Note that you cannot deploy the "Windows target" until the domain controller is up and running.

## Azure-Specific Features

### Managed Identity Integration
The StrongDM Gateway and Relay are configured with Azure managed identities, allowing secure authentication to Azure Key Vault without storing credentials.

### Service Principal Management
The Azure Read-Only service principal passwords expire every 10 days for security. You'll need to re-run `terraform apply` to update the password in StrongDM.

### HashiCorp Vault Integration
When enabled, HashiCorp Vault is configured to authenticate using the gateway's managed identity, providing all privileges to the kv/ path by default.

## Training Scenarios

This lab environment supports various training scenarios:

1. **Database Access Management**: Configure secure access to PostgreSQL and SQL Server databases with Azure Key Vault integration
2. **Server Access Control**: Manage Windows and Linux server access with certificate authentication and Active Directory integration
3. **Kubernetes Integration**: Demonstrate AKS cluster access management with kubectl and container workloads
4. **Cloud Permissions**: Show controlled Azure resources access through service principals and CLI tools
5. **Secret Management**: Illustrate integration with HashiCorp Vault and Azure Key Vault for enterprise secret management
6. **Multi-Platform Support**: Demonstrate consistent access patterns across Windows, Linux, and container environments

## Troubleshooting

Common issues and their solutions:

1. **Connection Failures**: Verify security groups allow traffic on required ports
2. **Authentication Issues**: Check the SDM API credentials and permissions
3. **Windows Setup Problems**: Examine C:\ for flag files to determine current setup stage

## Infrastructure Diagram
Once deployed, you can expect your resource group to look like the example below

![Azure Lab Architecture](doc/partnertraining.png?raw=true)

## Contributing

Feel free to submit issues or pull requests to improve the lab environment.

## Issues, comments, feedback
This repository is maintained with :blue_heart: by [Hamish](https://github.com/HameArm), [Nico](https://github.com/ncorrare) and other members of the [StrongDM](https://github.com/strongdm) team.
Please send us your issues and PR through the GitHub functionality, and we will get to them as soon as possible.
