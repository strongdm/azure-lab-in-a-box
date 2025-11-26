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
  validation {
    condition = contains([
      "eastus", "eastus2", "centralus", "northcentralus", "southcentralus", "westcentralus",
      "westus", "westus2", "westus3", "canadacentral", "canadaeast", "brazilsouth",
      "northeurope", "westeurope", "uksouth", "ukwest", "francecentral", "germanycenter",
      "norwayeast", "switzerlandnorth", "japaneast", "japanwest", "koreacentral",
      "australiaeast", "australiasoutheast", "southafricanorth", "southeastasia",
      "eastasia", "centralindia", "southindia", "westindia"
    ], var.region)
    error_message = "The region must be a valid Azure region."
  }
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

// Flag to enable creation of Cosmos DB with MongoDB API (equivalent to AWS DocumentDB)
variable "create_cosmosdb" {
  description = "Flag to create an Azure Cosmos DB instance with MongoDB API"
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

// Flag to enable creation of Azure Blob Storage read-only access (equivalent to AWS S3 read-only)
variable "create_blob_ro" {
  description = "Create a service principal with read-only access to Azure Blob Storage"
  type        = bool
  default     = false
}

// Flag to enable creation of Azure Blob Storage full access (equivalent to AWS S3 full access)
variable "create_blob_full" {
  description = "Create a service principal with full access to Azure Blob Storage"
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
// VM Size configuration variables
//

// VM sizes for different infrastructure components
variable "vm_sizes" {
  description = "VM sizes for different components in the lab environment"
  type = object({
    gateway           = optional(string, "Standard_B1s")
    relay             = optional(string, "Standard_B1s")
    domain_controller = optional(string, "Standard_D2_v3")
    windows_target    = optional(string, "Standard_D2_v3")
    linux_target      = optional(string, "Standard_B1s")
    vault             = optional(string, "Standard_B1s")
  })
  default = {}
}

// AKS node pool VM size
variable "aks_node_size" {
  description = "VM size for AKS node pool"
  type        = string
  default     = "Standard_D2_v3"
  validation {
    condition = contains([
      "Standard_B2s", "Standard_B2ms", "Standard_B4ms",
      "Standard_D2s_v3", "Standard_D2_v3", "Standard_D4s_v3", "Standard_D4_v3",
      "Standard_D2s_v4", "Standard_D2_v4", "Standard_D4s_v4", "Standard_D4_v4",
      "Standard_DS2_v2", "Standard_DS3_v2", "Standard_DS4_v2"
    ], var.aks_node_size)
    error_message = "AKS node size must be a supported VM size for Azure Kubernetes Service."
  }
}

// PostgreSQL database SKU
variable "postgresql_sku" {
  description = "PostgreSQL database SKU"
  type        = string
  default     = "B_Standard_B2s"
  validation {
    condition     = can(regex("^(B_|GP_|MO_)", var.postgresql_sku))
    error_message = "PostgreSQL SKU must start with B_ (Burstable), GP_ (General Purpose), or MO_ (Memory Optimized)."
  }
}

//
// Service and networking configuration
//

// Standard ports used by various services
variable "service_ports" {
  description = "Standard ports used by various services in the lab environment (StrongDM gateway port 5000 is fixed)"
  type = object({
    ssh        = optional(number, 22)
    rdp        = optional(number, 3389)
    sql_server = optional(number, 1433)
    postgresql = optional(number, 5432)
    vault      = optional(number, 8200)
  })
  default = {}
  validation {
    condition = (
      var.service_ports.ssh >= 1 && var.service_ports.ssh <= 65535 &&
      var.service_ports.rdp >= 1 && var.service_ports.rdp <= 65535
    )
    error_message = "All port numbers must be between 1 and 65535."
  }
}

// StrongDM gateway port - fixed at 5000 (well-known port expected by clients)
locals {
  strongdm_gateway_port = 5000
}

// Default administrative usernames
variable "admin_usernames" {
  description = "Default administrative usernames for various systems"
  type = object({
    linux_admin    = optional(string, "azureuser")
    windows_admin  = optional(string, "azureadmin")
    postgres_admin = optional(string, "pgadmin")
  })
  default = {}
}

// StrongDM node naming configuration
variable "strongdm_naming" {
  description = "Naming configuration for StrongDM nodes and resources"
  type = object({
    gateway_prefix = optional(string, "sdm-lab-gateway")
    relay_prefix   = optional(string, "sdm-lab-relay")
    domain_name    = optional(string, "strongdm.local")
  })
  default = {}
}

//
// Tagging and naming variables
//

// Tags to apply to all StrongDM resources for organization
variable "tagset" {
  description = "Set of Tags to apply to StrongDM resources"
  type        = map(string)
  validation {
    condition     = length(var.tagset) <= 50
    error_message = "Maximum of 50 tags allowed per resource in Azure."
  }
  validation {
    condition = alltrue([
      for k, v in var.tagset : length(k) >= 1 && length(k) <= 128 && length(v) <= 256
    ])
    error_message = "Tag keys must be 1-128 characters and values must be 0-256 characters."
  }
}

// Naming prefix for all resources (must be lowercase)
variable "name" {
  description = "Arbitrary string to add to resources"
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9]*$", var.name))
    error_message = "The name must start with a lowercase letter and contain only lowercase letters and numbers."
  }
  validation {
    condition     = length(var.name) >= 2 && length(var.name) <= 10
    error_message = "The name must be between 2 and 10 characters long."
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
  description = "Onboard domain_users into StrongDM for Management and credential rotation. WARNING: This requires domain controller to be fully configured with LDAPS. Deploy with this=false first, then enable after DC is running."
  type        = bool
  default     = false
  validation {
    condition     = var.create_managedsecrets ? var.create_domain_controller : true
    error_message = "create_managedsecrets requires create_domain_controller to be true."
  }
}