variable "subnet" {
  description = "Subnet id in which to deploy the system"
  type        = string
  default     = null
}

variable "rg" {
  description = "Resource group in which to deploy the system"
  type        = string
  default     = null
}

variable "region" {
  description = "Azure Region to create resources on"
  type        = string
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
  default     = "sdmadmin"
}

variable "domain_password" {
  description = "Password of the domain admin to join"
  type        = string
  default     = null
}

variable "domain_admin" {
  description = "Username of the domain admin to join"
  type        = string
  default     = null
}

variable "domain_name" {
  description = "Domain name to join"
  type        = string
  default     = null
}

variable "dns" {
  description = "DNS Server (Domain Controller IP)"
  type        = string
  default     = null
}

variable "vm_size" {
  description = "Azure VM size for the Windows target"
  type        = string
  default     = "Standard_DS1_v2"
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
    Name    = "sdm-${var.name}-windows"
    }
  )
}
