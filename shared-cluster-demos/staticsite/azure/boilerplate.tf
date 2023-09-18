terraform {
  backend "azurerm" {
    resource_group_name  = "my-terraform-resource-group"
    storage_account_name = "mystorageaccount"
    container_name       = "myblobcontainer"
    subscription_id      = "555-555-555-555"
    key                  = "cluster-staticsite-demo.tfstate"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.58.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">=2.37.2"
    }
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = ">=0.4.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">=0.9.1"
    }
    local = {
      source = "hashicorp/local"
      version = ">=2.4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "555-555-555-555"
}

data "azurerm_client_config" "main" {}

data "azurerm_resource_group" "main" {
  name = "my-static-site-demo-rg"
}