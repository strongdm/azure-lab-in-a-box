variable "region" {
    description = "Azure Region to create resources on"
    type        = "string"
    default     =  "ukwest"
}

variable "name" {
  description = "Arbitrary string to add to resources"
  type        = string
}

variable "tagset" {
  description = "Set of Tags to apply to StrongDM resources"
  type        = map(string)
}

locals {
  thistagset = merge (var.tagset, {
    class   = "sdminfra"
    }
  )
}