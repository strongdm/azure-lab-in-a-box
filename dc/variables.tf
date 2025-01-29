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
  default     = "sdmadmin"
}

variable "region" {
    description = "Azure Region to create resources on"
    type        = string
    default     =  "ukwest"
}

variable "rg" {
    description = "Name of existing resource group to provision resources on"
    type        = string
    default     = null
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
  thistagset = merge (var.tagset, {
    network = "Private"
    class   = "sdminfra"
    Name    = "sdm-${var.name}-domain-controller"
    }
  )  
}
