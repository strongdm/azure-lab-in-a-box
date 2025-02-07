terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3"
    }
   sdm = {
      source = "strongdm/sdm"
      version = ">=3.3.0"
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


provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    virtual_machine {
      delete_os_disk_on_deletion             = true
    }
  }

}

provider "azuread" {}

data "azurerm_subscription" "subscription" {}

data "azurerm_client_config" "current" {}

data "env_var" "sdm_api" {
  id = "SDM_API_HOST"
}
