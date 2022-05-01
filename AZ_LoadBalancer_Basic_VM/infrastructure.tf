resource "azurerm_resource_group" "eastcoast-rg" {
    name     = "Contoso-East-RG"
    location = "eastus"
}


resource "azurerm_virtual_network" "east-vnet" {
    name                = "east-vnet"
    location            = azurerm_resource_group.eastcoast-rg.location
    resource_group_name = azurerm_resource_group.eastcoast-rg.name
    address_space       = ["10.6.0.0/16"]
}


resource "azurerm_subnet" "east-sub" {
    name                 = "default"
    resource_group_name  = azurerm_resource_group.eastcoast-rg.name
    virtual_network_name = azurerm_virtual_network.east-vnet.name
    address_prefixes     = ["10.6.0.0/24"]
}


resource "azurerm_network_security_group" "eastNSG" {
  name                = "eastNSG"
  location            = azurerm_resource_group.eastcoast-rg.location
  resource_group_name = azurerm_resource_group.eastcoast-rg.name

  security_rule {
    name                       = "allowEverything"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}


resource "azurerm_network_interface" "boston-nic" {
    name                 = "boston-nic"
    location             = azurerm_resource_group.eastcoast-rg.location
    resource_group_name  = azurerm_resource_group.eastcoast-rg.name
    enable_ip_forwarding = true

    ip_configuration {
    name                          = "bostonIP-Config"
    subnet_id                     = azurerm_subnet.east-sub.id
    private_ip_address_allocation = "Static"
    private_ip_address = "10.6.0.30"
    }
}


resource "azurerm_network_interface" "atlanta-nic" {
    name                 = "atlanta-nic"
    location             = azurerm_resource_group.eastcoast-rg.location
    resource_group_name  = azurerm_resource_group.eastcoast-rg.name
    enable_ip_forwarding = true

    ip_configuration {
    name                          = "atlantaIP-Config"
    subnet_id                     = azurerm_subnet.east-sub.id
    private_ip_address_allocation = "Static"
    private_ip_address = "10.6.0.40"
    }
}


resource "azurerm_public_ip" "balancer-pip" {
    name                         = "loadbalance-ip"
    location            = azurerm_resource_group.eastcoast-rg.location
    resource_group_name = azurerm_resource_group.eastcoast-rg.name
    allocation_method   = "Static"
}

