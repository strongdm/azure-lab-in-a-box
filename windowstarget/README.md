# Windows Target Module

This module creates a Windows Server VM that joins the Active Directory domain for RDP access demonstrations.

## Features

- Windows Server 2019 VM
- Automatic domain join
- StrongDM RDP certificate authentication
- Private network deployment

## Usage

```hcl
module "windowstarget" {
  source = "../windowstarget"

  name            = "mylab"
  region          = "ukwest"
  rg              = "my-resource-group"
  subnet          = module.network.relay_subnet
  dns             = module.dc.dc_ip
  domain_name     = module.dc.domain
  domain_admin    = module.dc.dc_username
  domain_password = module.dc.dc_password
  tagset          = var.tagset
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
| dns | DNS server (DC IP) | string | null |
| domain_name | Domain name to join | string | null |
| domain_admin | Domain admin username | string | null |
| domain_password | Domain admin password | string | null |
| target_user | Local admin username | string | "sdmadmin" |
| vm_size | VM size | string | "Standard_DS1_v2" |

## Outputs

| Name | Description |
|------|-------------|
| ip | VM private IP address |
| username | Admin username |
| password | Admin password |
| thistagset | Tags applied to resources |

## Notes

- Requires domain controller to be deployed and running first
- Automatically joins the AD domain during provisioning
