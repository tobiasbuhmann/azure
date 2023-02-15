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