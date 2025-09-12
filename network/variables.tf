variable "region" {
  description = "Azure Region to create resources on"
  type        = string
}

// Network CIDR configuration
variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
  validation {
    condition = alltrue([
      for cidr in var.vnet_address_space : can(cidrhost(cidr, 0))
    ])
    error_message = "All address spaces must be valid CIDR blocks."
  }
}

variable "gateway_subnet_prefix" {
  description = "Address prefix for the gateway subnet"
  type        = string
  default     = "10.0.1.0/24"
  validation {
    condition     = can(cidrhost(var.gateway_subnet_prefix, 0))
    error_message = "Gateway subnet prefix must be a valid CIDR block."
  }
}

variable "relay_subnet_prefix" {
  description = "Address prefix for the relay subnet"
  type        = string
  default     = "10.0.2.0/24"
  validation {
    condition     = can(cidrhost(var.relay_subnet_prefix, 0))
    error_message = "Relay subnet prefix must be a valid CIDR block."
  }
}

// Security configuration for SSH access
variable "allowed_ssh_cidr_blocks" {
  description = "List of CIDR blocks allowed to access SSH (port 22). Use ['0.0.0.0/0'] for unrestricted access (not recommended for production)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
  validation {
    condition     = length(var.allowed_ssh_cidr_blocks) > 0
    error_message = "At least one CIDR block must be specified for SSH access."
  }
}

// StrongDM service configuration
variable "strongdm_port" {
  description = "Port used by StrongDM gateway service"
  type        = number
  default     = 5000
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
  thistagset = merge(var.tagset, {
    class = "sdminfra"
    }
  )

  # Convert CIDR blocks to comma-separated string for NSG rules
  ssh_source_addresses = length(var.allowed_ssh_cidr_blocks) == 1 ? var.allowed_ssh_cidr_blocks[0] : join(",", var.allowed_ssh_cidr_blocks)
}