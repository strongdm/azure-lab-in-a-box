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

variable "tagset" {
  description = "Set of Tags to apply to StrongDM resources"
  type        = map(string)
}

variable "name" {
  description = "Arbitrary string to add to resources"
  type        = string
}

locals {
  thistagset = merge (var.tagset, {
    class   = "sdminfra"
    }
  )
}