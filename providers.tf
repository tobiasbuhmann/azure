# Specify the providers to use
terraform {
  cloud {
    organization = "tobias-buhmann"
    hostname = "app.terraform.io"

    workspaces {
      name = "azure-vcs"
    }
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
    azapi = {
      source = "Azure/azapi"
    }
  }
}

# Configure 'AzureRM' provider and subscriptions
provider "azurerm" {
  features {}
}

# Configure 'AzAPI' provider and subscriptions
provider "azapi" {
}