variable "subnet" {
  description = "Subnet id in which to deploy the system"
  type        = string
  default     = null
}

variable "tagset" {
  description = "Set of Tags to apply to StrongDM resources"
  type        = map(string)
}

variable "sshca" {
  description = "CA Certificate of the SSH CA"
  type        = string
}

variable "akvdns" {
  description = "DNS Suffix of the Azure Key vault used for Seal Wrap"
  type        = string
}

variable "akvid" {
  description = "ID of the Azure Key Vault"
  type        = string
}

variable "name" {
  description = "Arbitrary string to add to resources"
  type        = string
}

variable "target_user" {
  description = "User for Health check"
  type        = string
  default     = "sdmadmin"
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

variable "rgid" {
  description = "ID of existing resource group to provision resources on"
  type        = string
  default     = null
}

variable "vault_version" {
  description = "Version of HashiCorp Vault to download"
  type        = string
  default     = "1.18.4"
}

variable "vm_size" {
  description = "Azure VM size for the HashiCorp Vault instance"
  type        = string
  default     = "Standard_B1s"
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
    class   = "sdminfra"
    Name    = "sdm-${var.name}-hashicorp-vault"
    }
  )
}