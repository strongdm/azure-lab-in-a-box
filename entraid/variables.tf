/*
 * Entra ID Module Variables
 * Input variables for configuring Microsoft Entra ID group management in StrongDM
 */

variable "name" {
  description = "Arbitrary string to add to resources"
  type        = string
}

variable "tagset" {
  description = "Set of Tags to apply to StrongDM resources"
  type        = map(string)
}

variable "tenant_id" {
  description = "Azure AD/Entra tenant ID"
  type        = string
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "rg" {
  description = "Resource Group name"
  type        = string
}

variable "gateway_principal_id" {
  description = "Principal ID of the gateway managed identity for role assignments"
  type        = string
}

locals {
  thistagset = merge(var.tagset, {
    network = "Public"
    class   = "target"
  })
}
