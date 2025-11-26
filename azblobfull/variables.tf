#--------------------------------------------------------------
# Azure Blob Storage Full Access Module Variables
#
# This file defines the input variables for the Blob Storage full access module,
# which creates a service principal with full access to Azure Blob Storage.
# This is the Azure equivalent of AWS S3 full access.
#--------------------------------------------------------------

variable "name" {
  description = "Arbitrary string to add to resources for identification"
  type        = string
}

variable "tagset" {
  description = "Set of Tags to apply to StrongDM resources"
  type        = map(string)
}

variable "subscription" {
  description = "Azure subscription ID for role assignment scope"
  type        = string
}

variable "rg" {
  description = "Resource Group name for role assignment scope"
  type        = string
}

variable "storage_account_id" {
  description = "Storage account ID for scoped access (optional - if null, a new storage account is created)"
  type        = string
  default     = null
}

locals {
  thistagset = merge(var.tagset, {
    network     = "Public"
    class       = "target"
    service     = "BlobStorage"
    permissions = "full"
  })
}
