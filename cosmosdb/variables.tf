#--------------------------------------------------------------
# Cosmos DB Module Variables
#
# This file defines the input variables for the Cosmos DB module, which is used
# to create a MongoDB-compatible database service in Azure (equivalent to AWS
# DocumentDB). These variables control aspects such as:
# - Network configuration (virtual network, subnet)
# - Instance configuration
# - Database credentials
# - Resource naming and tagging
#--------------------------------------------------------------

variable "tagset" {
  description = "Set of Tags to apply to StrongDM resources"
  type        = map(string)
}

variable "name" {
  description = "Arbitrary string to add to resources"
  type        = string
}

variable "region" {
  description = "Azure Region to create resources on"
  type        = string
}

variable "rg" {
  description = "Name of existing resource group to provision resources on"
  type        = string
}

variable "relay_ip" {
  description = "Relay IP to be allowed access through firewall"
  type        = string
  default     = null
}

variable "key_vault_id" {
  description = "ID of the Key Vault where to store secrets"
  type        = string
  default     = null
}

variable "username" {
  description = "Username for Cosmos DB (used in connection string)"
  type        = string
  default     = "cosmosadmin"
}

variable "throughput" {
  description = "The throughput of the MongoDB database (RU/s). Minimum is 400."
  type        = number
  default     = 400
}

variable "db_name" {
  description = "Name of the MongoDB database to create"
  type        = string
  default     = "labdb"
}

resource "random_password" "cosmosdb_password" {
  length      = 20
  special     = false
  min_numeric = 1
  min_upper   = 1
  min_lower   = 1
}

locals {
  admin_password = random_password.cosmosdb_password.result
  thistagset = merge(var.tagset, {
    network = "Private"
    class   = "target"
    Name    = "sdm-${var.name}-cosmosdb"
  })
}
