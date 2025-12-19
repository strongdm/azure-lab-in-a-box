# Secrets Management Module

This module creates StrongDM managed secrets for Active Directory domain users, enabling credential rotation and secure access management.

## Features

- Creates StrongDM managed secrets for domain users
- Integrates with StrongDM secret engine for credential rotation
- Links LDAP user DNs to managed secrets

## Usage

```hcl
module "secretsmgmt" {
  source = "../secretsmgmt"

  se_pubkey      = var.secret_engine_public_key
  se_id          = var.secret_engine_id
  tags           = var.tagset
  user_dn        = "CN=jsmith,CN=Users,DC=strongdm,DC=local"
  SamAccountName = "jsmith"
}
```

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| se_pubkey | Public key of the secret engine | string | - |
| se_id | ID of the secret engine | string | - |
| tags | Tags to apply to the managed secret | map(any) | - |
| user_dn | LDAP User DN for the managed user | string | - |
| SamAccountName | Username of the account | string | - |

## Notes

- Requires domain controller to be fully configured with LDAPS
- Used internally by the main module when `create_managedsecrets = true`
