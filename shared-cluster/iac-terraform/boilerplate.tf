terraform {
  backend "azurerm" {
    resource_group_name  = "my-resource-group"
    storage_account_name = "mystorageaccount"
    container_name       = "myblobcontainer"
    subscription_id      = "555-555-5555"
    key                  = "clusterz.tfstate"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.59.0"
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
    tls = {
      source  = "hashicorp/tls"
      version = ">=4.0.4"
    }
    random = {
      source  = "hashicorp/random"
      version = ">=3.5.1"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "555-555-555-555" # SCED-NPRD
}

provider "azurerm" {
  features {}
  subscription_id = "555-555-555-555"
  alias           = "SCEDCORE"
}


provider "azurerm" {
  features {}
  subscription_id = "555-555-555-555"
  alias           = "SCEDPROD"
}

provider "azuredevops" {
  org_service_url = "https://dev.azure.com/my-org"
}


data "azurerm_client_config" "main" {}


data "azuread_group" "cloudops" {
  object_id = "555-555-555-555"
}