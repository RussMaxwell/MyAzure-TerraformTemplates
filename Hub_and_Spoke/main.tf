terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">=2.99.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  subscription_id = var.subscriptionID
  tenant_id       = var.tenantID
  features {}
}