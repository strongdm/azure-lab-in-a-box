variable "subnet" {
  description = "Subnet id in which to deploy the system"
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

variable "target_user" {
  description = "User for Health check"
  type        = string
  default     = "sdmadmin"
}

variable "region" {
  description = "Azure Region to create resources on"
  type        = string
}

variable "rg" {
  description = "Name of existing resource group to provision resources on"
  type        = string
  default     = null
}

variable "vm_size" {
  description = "Azure VM size for the domain controller"
  type        = string
  default     = "Standard_DS1_v2"
}

resource "random_password" "admin_password" {
  length      = 20
  special     = true
  min_numeric = 1
  min_upper   = 1
  min_lower   = 1
  min_special = 0
}

locals {
  admin_password = random_password.admin_password.result
  is_linux       = length(regexall("c:", lower(abspath(path.root)))) > 0
  interpreter    = local.is_linux ? "powershell" : "bash"
  script         = format("%s/%s", path.module, local.is_linux ? "windowsrdpca.ps1" : "windowsrdpca.sh")
  thistagset = merge(var.tagset, {
    network = "Private"
    class   = "sdminfra"
    Name    = "sdm-${var.name}-domain-controller"
    }
  )
}

variable "rdpca" {
  description = "RDP CA to import into the domain controller"
  type        = string
}

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