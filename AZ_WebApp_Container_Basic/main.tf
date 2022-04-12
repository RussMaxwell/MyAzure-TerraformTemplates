locals {
    subscription_id    = "<input SubscriptionID>"
    tenant_id          = "<input TenantID>"
    app-location       = "eastus"
    app-resource-group = "Contoso-App-rg"
    webApp-Name        = "<Input Unique WebApplication Name"
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
  subscription_id = local.subscription_id
  tenant_id       = local.tenant_id
  features {}
}


resource "azurerm_resource_group" "ContosoApp-RG" {
  name     = local.app-resource-group
  location = local.app-location
}


resource "azurerm_service_plan" "Contoso-ServicePlan" {
  name                = "contosoASP"
  resource_group_name = azurerm_resource_group.ContosoApp-RG.name
  location            = azurerm_resource_group.ContosoApp-RG.location
  sku_name            = "B1"
  os_type             = "Linux"
}


resource "azurerm_linux_web_app" "Contoso-WebApp" {
  name                = local.webApp-Name
  resource_group_name = azurerm_resource_group.ContosoApp-RG.name
  location            = azurerm_service_plan.Contoso-ServicePlan.location
  service_plan_id     = azurerm_service_plan.Contoso-ServicePlan.id

  identity {
      type = "SystemAssigned"
  }

  site_config {
      container_registry_use_managed_identity = true

      application_stack {
      docker_image = "russmax/testwebapp"
      docker_image_tag = "latest"
      }
    }
}