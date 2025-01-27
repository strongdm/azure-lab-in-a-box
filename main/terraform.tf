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
