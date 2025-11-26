#--------------------------------------------------------------
# Azure Data Factory Module Variables
#
# This file defines the input variables for the Data Factory module,
# which creates a service principal with full access to Azure Data Factory.
# This is the Azure equivalent of AWS Glue full access.
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

variable "region" {
  description = "Azure region for Data Factory deployment"
  type        = string
}

locals {
  thistagset = merge(var.tagset, {
    network     = "Public"
    class       = "target"
    service     = "DataFactory"
    permissions = "full"
  })
}
