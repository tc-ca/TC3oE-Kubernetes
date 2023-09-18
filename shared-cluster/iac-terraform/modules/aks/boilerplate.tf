terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      configuration_aliases = [azurerm.dns, azurerm.vnet]
    }
    azuread = {
      source = "hashicorp/azuread"
    }
    azuredevops = {
      source = "microsoft/azuredevops"
    }
  }
}
provider "azurerm" {
  features {}
  subscription_id = "555-555-55555"
  alias           = "SCEDCORE"
}
data "azurerm_client_config" "main" {}

variable "resource_group_name" {
  type = string
}
data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}