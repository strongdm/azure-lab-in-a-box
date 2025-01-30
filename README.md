# StrongDM Lab in a Box for Azure
> [!CAUTION]
> This is currently work in progress and could be broken at any time.
> We will attempt to keep tagged versions "working"


This repository contains a set of modules that enable the user to deploy a quick lab to evaluate StrongDM capabilities, including
- An optional Resource Group, VPC, Virtual Network, Security groups, NAT and Gateway sets
- A StrongDM Gateway and a relay with a managed identity allowing them to use Azure Key Vault
- An SSH Target using StrongDM's CA for Authentication 
- A PostgreSQL target
- Azure Read Only access on AZ CLI
- A Windows domain controller 
- A Windows server target using certificate authentication 
- An AKS Cluster (WIP)

All resources are tagged according to variables set in the module, in order to set adequate access roles in StrongDM

## Prerequisites
In addition to the usual access credentials for Azure, the modules require an access key to StrongDM with the following privileges:

 ![StrongDM Permissions](doc/strongdm-permissions.png?raw=true)

Export the environment variables

```bash
export SDM_API_ACCESS_KEY=auth-aaabbbbcccccc
export SDM_API_SECRET_KEY=jksafhlksdhfsahgghdslkhaslghasdlkghlasdkhglkshg
```
Make sure you're logged into sdm with 
```sdm login```
specially if you're using the Windows CA target, as it will use the local process to pull the Windows CA Certificate

## Variables
- Network
  - rg: Id of an existing VPC. If it's null a new VPC will be created. If this variable is provided all of the related network variables will be required
  - gateway_subnet: ID of a Public Subnet
  - relay_subnet(-b,-c): Private subnets to deploy resources
  - private_sg: Id of the Security group for private machines (reachable by the relay)
  - public_sg: ID of the public security group
The module will not verify if the right network configuration is set so make sure to refer to the SDM [Ports Guide](https://www.strongdm.com/docs/admin/deployment/ports-guide/)

- Resources
  - create_linux_target: Create a linux target resource with ssh ca authentication
  - create_postgresql: Create an RDS Postgresql database using password authentication, retrieving credentials from secrets manager
  - create_aks: Create a Kubernetes Cluster
  - create_domain_controller: Create a Windows Domain Controller
  - create_windows_target: Create a Windows RDP target
  - create_az_ro: Create a Role that can be assumed by the gateway to access AWS
 
- Other Variables:
  - tagset: tags to apply to all resources
  - name: an arbitrary string that will be added to all resource names


You can reference the [terraform.tfvars.example](main/terraform.tfvars.example) file in the main module for reference

## Getting started

Within the main module, do the usual steps

```bash
cd main
terraform init
terraform plan
terraform apply
``` 

## Windows Warnings
Setting up a Domain controller takes several reboots. This is implemented by a persistent Powershell script that runs at each reboot and has flow control through creating some "flag files" in c:\ with the "done" extension as each step is completed. You can reference the full Powershell script [here](dc/install-dc.ps1.tpl).

This means that of cource that you cannot deploy the "Windows target" until the domain controller is up and running
