variable "subnet" {
  description = "Subnet id in which to deploy the system"
  type        = string
  default     = null
}

variable "tagset" {
  description = "Set of Tags to apply to StrongDM resources"
  type        = map(string)
}

variable "name" {
  description = "Arbitrary string to add to resources"
  type        = string
}

variable "target_user" {
  description = "User for Health check"
  type        = string
  default     = "pgadmin"
}

variable "region" {
  description = "Azure Region to create resources on"
  type        = string
}

variable "rg" {
  description = "Name of existing resource group to provision resources on"
  type        = string
  default     = null
}

variable "relay_ip" {
  description = "Relay IP to be allowed access"
  type        = string
  default     = null
}

variable "key_vault_id" {
  description = "ID of the Key Vault where to store secrets"
  type        = string
  default     = null
}

variable "db_sku" {
  description = "PostgreSQL database SKU"
  type        = string
  default     = "B_Standard_B2s"
}

resource "random_password" "admin_password" {
  length      = 20
  special     = true
  min_numeric = 1
  min_upper   = 1
  min_lower   = 1
  min_special = 0
}

locals {
  admin_password = random_password.admin_password.result
  thistagset = merge(var.tagset, {
    network = "Private"
    class   = "target"
    Name    = "sdm-${var.name}-postgresql"
    }
  )
}