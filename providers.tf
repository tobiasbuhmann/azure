# Providers specification
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
    azapi = {
      source = "Azure/azapi"
    }
    spacelift = {
      source = "spacelift-io/spacelift"
    }
  }
}

# Providers configuration
provider "azurerm" {
  features {}
}

provider "azapi" {}

provider "spacelift" {}
