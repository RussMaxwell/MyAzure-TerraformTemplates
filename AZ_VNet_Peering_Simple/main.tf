locals {
    subscriptionID = "<insert Subscription ID>"
    tenantID       = "<insert Tenant ID>"
}

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
  subscription_id = local.subscriptionID
  tenant_id       = local.tenantID
  features {}
}
