# Providers specification
terraform {
  cloud {
    organization = "tobias-buhmann"
    workspaces {
      name = "azure-vcs"
    }
  }

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    azapi = {
      source = "Azure/azapi"
    }
  }
}

# Providers configuration
provider "azurerm" {
  features {}
}

provider "azapi" {}
