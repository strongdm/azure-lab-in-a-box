
terraform {
  required_providers {

    sdm = {
      source  = "strongdm/sdm"
      version = "~> 17.0"
    }
  }

  required_version = ">= 1.5.0"
}