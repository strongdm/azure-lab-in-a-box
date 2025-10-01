/*
 * Main Terraform configuration file
 * This file configures the required providers for the StrongDM Lab in a Box deployment
 * It includes providers for Azure Resource Manager, StrongDM, Azure Active Directory, 
 * and a helper provider for environment variables
 */
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3"
    }
    sdm = {
      source  = "strongdm/sdm"
      version = "~> 14.20"
    }
    azuread = {
      source = "hashicorp/azuread"
    }
    env = {
      source = "tcarreira/env"
    }
  }

  required_version = ">= 1.1.0"
}

/* 
 * Azure Resource Manager provider configuration
 * Configures the behavior for resource deletion:
 * - Allows deletion of resource groups even when they contain resources
 * - Automatically deletes OS disks when VMs are deleted
 */
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    virtual_machine {
      delete_os_disk_on_deletion = true
    }
  }

}

// Azure Active Directory provider with default configuration
provider "azuread" {}

// Data source for current Azure subscription information
data "azurerm_subscription" "subscription" {}

// Data source for current Azure client configuration (used for authentication details)
data "azurerm_client_config" "current" {}

// Data source to fetch StrongDM API host from environment variables
data "env_var" "sdm_api" {
  id = "SDM_API_HOST"
}

// Validation to ensure SDM_API_HOST is in the correct format
locals {
  sdm_api_validation = (
    data.env_var.sdm_api.value == "" ? true :
    can(regex("^[a-zA-Z0-9.-]+:[0-9]+$", data.env_var.sdm_api.value)) ? true :
    tobool("ERROR: SDM_API_HOST must be in format 'hostname:port' (e.g., 'app.strongdm.com:443' or 'api.eu.strongdm.com:443'). Do NOT include 'http://' or 'https://' prefix. Current value: '${data.env_var.sdm_api.value}'")
  )
}
