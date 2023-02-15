# Specify the version of the providers to use
terraform {
  cloud {
    organization = "tobias-buhmann"
    hostname = "app.terraform.io"

    workspaces {
      name = "azure"
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

provider "azurerm" {
  alias = "subscription"
  tenant_id = "e2367125-41e3-4124-bacc-5ee027d27287"
  subscription_id = "62323a37-791c-4589-a069-da52bea40762"
  features {}
}

# Configure 'AzAPI' provider and subscriptions
provider "azapi" {
}

provider "azapi" {
  alias = "subscription"
  tenant_id = "e2367125-41e3-4124-bacc-5ee027d27287"
  subscription_id = "62323a37-791c-4589-a069-da52bea40762"
}