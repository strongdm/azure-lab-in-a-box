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

variable "sshca" {
  description = "CA Certificate of the SSH CA"
  type        = string
}

variable "target_user" {
  description = "User for Health check"
  type        = string
  default     = "azureuser"
}

variable "region" {
  description = "Azure Region to create resources on"
  type        = string
  default     = "ukwest"
}

variable "rg" {
  description = "Resource Group for the readonly principal"
  type        = string
}

variable "vm_size" {
  description = "Azure VM size for the Linux target"
  type        = string
  default     = "Standard_B1s"
}

locals {
  thistagset = merge(var.tagset, {
    network = "Public"
    class   = "target"
    }
  )
}
