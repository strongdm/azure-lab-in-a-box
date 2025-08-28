/*
 * Main Module Variables
 * This file defines all the input variables for the StrongDM Lab in a Box
 * Variables are grouped into:
 * - Network configuration variables
 * - Resource creation flags
 * - Tagging and naming variables
 */

//
// Network configuration variables
//

// Azure region to deploy all resources
variable "region" {
  description = "Azure Region to create resources on"
  type        = string
  default     = "ukwest"
}

// Existing resource group name (optional)
variable "rg" {
  description = "Name of existing resource group to provision resources on"
  type        = string
  default     = null
}

// Existing virtual network name (optional)
variable "vn" {
  description = "Name of existing Virtual Network to provision resources on"
  type        = string
  default     = null
}

// Existing public subnet for gateway components (optional)
variable "gateway_subnet" {
  description = "Use an existing public subnet. If nil a new subnet will be created"
  type        = string
  default     = null
}

// Existing private subnet for relay and target components (optional)
variable "relay_subnet" {
  description = "Use an existing private subnet. If nil a new subnet will be created"
  type        = string
  default     = null
}

//
// Resource creation flags
//

// Flag to enable creation of AKS (Kubernetes) cluster
variable "create_aks" {
  description = "Flag to create an Azure Kubernetes Service (AKS)"
  type        = bool
  default     = false
}

// Flag to enable creation of PostgreSQL database
variable "create_postgresql" {
  description = "Flag to create a PostgreSQL instance"
  type        = bool
  default     = false
}

// Flag to enable creation of MSSQL database
variable "create_mssql" {
  description = "Flag to create a Microsoft SQL Server instance"
  type        = bool
  default     = false
}

// Flag to enable creation of Windows Domain Controller
variable "create_domain_controller" {
  description = "Flag to create a domain controller"
  type        = bool
  default     = false
}

// Flag to enable creation of Windows target VM
variable "create_windows_target" {
  description = "Flag to create a Windows target (VM, instance, etc.)"
  type        = bool
  default     = false
}

// Flag to enable creation of Linux target VM
variable "create_linux_target" {
  description = "Flag to create a Linux target (VM, instance, etc.)"
  type        = bool
  default     = false
}

// Flag to enable creation of Azure Read-Only service principal
variable "create_az_ro" {
  description = "Create a Read Only principal for Azure access"
  type        = bool
  default     = false
}

// Flag to enable creation of HashiCorp Vault instance
variable "create_hcvault" {
  description = "Create a HashiCorp Vault Development Instance for testing"
  type        = bool
  default     = false
}

//
// Tagging and naming variables
//

// Tags to apply to all StrongDM resources for organization
variable "tagset" {
  description = "Set of Tags to apply to StrongDM resources"
  type        = map(string)
}

// Naming prefix for all resources (must be lowercase)
variable "name" {
  description = "Arbitrary string to add to resources"
  type        = string
  validation {
    condition     = can(regex("^([a-z])+$", var.name))
    error_message = "The string must be lowercase."
  }
}

#---------- Secrets Management Configuration ----------#
variable "domain_users" {
  description = "Set of map of users to be created in the Directory"
  type = set(object({
    SamAccountName = string
    GivenName      = string
    Surname        = string
    tags           = map(string)
  }))
  default = null
}

variable "create_managedsecrets" {
  description = "Onboard domain_users into StrongDM for Management and credential rotation"
  type        = bool
  default     = false
}