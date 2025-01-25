variable "region" {
    description = "Azure Region to create resources on"
    type        = "string"
    default     =  "ukwest"
}

variable "rg" {
    description = "Name of existing resource group to provision resources on"
    type        = string
    default     = null
}

variable "create_aks" {
  description = "Flag to create an Azure Kubernetes Service (AKS)"
  type        = bool
  default     = false
}

variable "create_postgresql" {
  description = "Flag to create a PostgreSQL instance"
  type        = bool
  default     = false
}

variable "create_domain_controller" {
  description = "Flag to create a domain controller"
  type        = bool
  default     = false
}

variable "create_windows_target" {
  description = "Flag to create a Windows target (VM, instance, etc.)"
  type        = bool
  default     = false
}

variable "create_linux_target" {
  description = "Flag to create a Linux target (VM, instance, etc.)"
  type        = bool
  default     = false
}

variable "tagset" {
  description = "Set of Tags to apply to StrongDM resources"
  type        = map(string)
}

variable "name" {
  description = "Arbitrary string to add to resources"
  type        = string
}