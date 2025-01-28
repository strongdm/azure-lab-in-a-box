variable "name" {
  description = "Arbitrary string to add to resources"
  type        = string
}

variable "tagset" {
  description = "Set of Tags to apply to StrongDM resources"
  type        = map(string)
}

variable "subscription" {
    description = "Azure subscription in which to provision the service account"
}

locals {
  thistagset = merge (var.tagset, {
    network = "Public"
    class   = "target"
    }
  )  
}

variable "rg" {
    description = "Resource Group for the readonly principal"
    type        = string
}