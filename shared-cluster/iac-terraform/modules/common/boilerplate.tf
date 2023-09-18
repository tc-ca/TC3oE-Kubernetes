terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    # azuread = {
    #   source = "hashicorp/azuread"
    # }
    azuredevops = {
      source = "microsoft/azuredevops"
    }
  }
}

variable "resource_group_name" {
  type = string
}
data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

# data "azurerm_client_config" "main" {}
