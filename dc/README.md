# Domain Controller Module

This module creates a Windows Server VM configured as an Active Directory Domain Controller.

## Features

- Windows Server 2019 with AD Domain Services
- StrongDM RDP CA certificate integration
- Automated domain controller promotion
- Support for domain user creation

## Usage

```hcl
module "dc" {
  source = "../dc"

  name    = "mylab"
  region  = "ukwest"
  rg      = "my-resource-group"
  subnet  = module.network.relay_subnet
  rdpca   = var.rdp_ca_certificate
  tagset  = var.tagset
}
```

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| name | Name prefix for resources | string | - |
| region | Azure region | string | - |
| rg | Resource group name | string | null |
| subnet | Subnet ID for deployment | string | null |
| tagset | Tags to apply to resources | map(string) | - |
| rdpca | RDP CA certificate | string | - |
| target_user | Admin username | string | "sdmadmin" |
| vm_size | VM size | string | "Standard_DS1_v2" |
| domain_users | Domain users to create | set(object) | null |

## Outputs

| Name | Description |
|------|-------------|
| dc_ip | Domain controller private IP |
| dc_username | Admin username |
| dc_password | Admin password |
| domain | Domain name (name.local) |
| netbios_domain | NetBIOS domain name |
| thistagset | Tags applied to resources |

## Notes

- Setup takes 15-30 minutes with multiple reboots
- Progress tracked via flag files in C:\
- Must be deployed before Windows targets
