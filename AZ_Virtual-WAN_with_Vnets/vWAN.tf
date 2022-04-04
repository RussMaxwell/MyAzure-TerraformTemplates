locals {
    virtualWAN-location       = "eastus"
    virtualWAN-resource-group = "Contoso-Virtual_WAN-rg"
    prefix-virtualWAN         = "Virtual_WAN"
}

resource "azurerm_resource_group" "virtualWAN-vnet-rg" {
    name     = local.virtualWAN-resource-group
    location = local.virtualWAN-location
}

resource "azurerm_virtual_wan" "contoso_virtualWAN" {
  name                = "contoso-virtualWAN"
  resource_group_name = azurerm_resource_group.virtualWAN-vnet-rg.name
  location            = azurerm_resource_group.virtualWAN-vnet-rg.location
  type                = "Standard"
}

resource "azurerm_virtual_hub" "contoso_virtualHub" {
  name                = "Contoso-virtualhub"
  resource_group_name = azurerm_resource_group.virtualWAN-vnet-rg.name
  location            = azurerm_resource_group.virtualWAN-vnet-rg.location
  virtual_wan_id      = azurerm_virtual_wan.contoso_virtualWAN.id
  address_prefix      = "10.5.0.0/23"
}

resource "azurerm_virtual_hub_connection" "connectVnet1" {
  name                      = "connect-Boston"
  virtual_hub_id            = azurerm_virtual_hub.contoso_virtualHub.id
  remote_virtual_network_id = azurerm_virtual_network.boston-vnet.id
}

resource "azurerm_virtual_hub_connection" "connectVnet2" {
  name                      = "connect-Atlanta"
  virtual_hub_id            = azurerm_virtual_hub.contoso_virtualHub.id
  remote_virtual_network_id = azurerm_virtual_network.Atlanta-vnet.id
}
