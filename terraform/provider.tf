terraform {

  cloud {

    organization = "logion"

    workspaces {
      name = "ai-review-pr-yt"
    }
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}

  storage_use_azuread = true
}
