locals {
  subscriptionID = "<input_SubscriptionID>"
  tenantID = "<input_tenantID>"
  lawsName = "<input_unique_name_4_LogAnalytics_Workspace>"
}

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "=2.99.0"
    }
  }
}


provider "azurerm" {
  # Configuration options
  subscription_id = local.subscriptionID
  tenant_id       = local.tenantID
  features {}
}



# Create a resource group in East US
resource "azurerm_resource_group" "ContosoEast" {
  name     = "ContosoMonitor"
  location = "East US"
}


resource "azurerm_log_analytics_workspace" "contosoLaws" {
  name                = local.lawsName
  location            = azurerm_resource_group.ContosoEast.location
  resource_group_name = azurerm_resource_group.ContosoEast.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}


resource "azurerm_application_insights" "contosoInsights" {
  name                = "contoso-appinsights"
  location            = azurerm_resource_group.ContosoEast.location
  resource_group_name = azurerm_resource_group.ContosoEast.name
  workspace_id        = azurerm_log_analytics_workspace.contosoLaws.id
  application_type    = "web"
}

