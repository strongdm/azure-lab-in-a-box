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

variable "vn" {
    description = "Name of existing Virtual Network to provision resources on"
    type        = string
    default     = null
}

variable "gateway_subnet" {
  description = "Use an existing public subnet. If nil a new subnet will be created"
  type        = string
  default     = null
}

variable "relay_subnet" {
  description = "Use an existing private subnet. If nil a new subnet will be created"
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

variable "create_mssql" {
  description = "Flag to create a Microsoft SQL Server instance"
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

variable "create_az_ro" {
  description = "Create a Read Only principal for Azure access"
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
  validation {
    condition     = can(regex("^([a-z])+$", var.name))
    error_message = "The string must be lowercase."
  }
}