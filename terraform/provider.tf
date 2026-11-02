terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  # State is stored in Azure blob storage. The storage account, container and key
  # are passed in at init time by the workflow (-backend-config).
  backend "azurerm" {}
}

provider "azurerm" {
  features {}

  storage_use_azuread = true
}
