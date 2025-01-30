variable "tagset" {
  description = "Set of Tags to apply to StrongDM resources"
  type        = map(string)
}

variable "name" {
  description = "Arbitrary string to add to resources"
  type        = string
}

variable "target_user" {
  description = "User for kubelets"
  type        = string
  default     = "k8sadmin"
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

variable "key_vault_id" {
    description = "ID of the Key Vault where to store secrets"
    type        = string
    default     = null
}

locals {
  thistagset = merge (var.tagset, {
    network = "Private"
    class   = "target"
    Name    = "sdm-${var.name}-aks"
    }
  )  
}