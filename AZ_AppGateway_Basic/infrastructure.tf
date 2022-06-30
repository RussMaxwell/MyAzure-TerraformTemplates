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


resource "azurerm_subnet" "fe-sub" {
    name                 = "frontendSubnet"
    resource_group_name  = azurerm_resource_group.eastcoast-rg.name
    virtual_network_name = azurerm_virtual_network.east-vnet.name
    address_prefixes     = ["10.6.1.0/24"]
}


resource "azurerm_subnet" "be-sub" {
    name                 = "backendSubnet"
    resource_group_name  = azurerm_resource_group.eastcoast-rg.name
    virtual_network_name = azurerm_virtual_network.east-vnet.name
    address_prefixes     = ["10.6.2.0/24"]
}


resource "azurerm_network_security_group" "eastNSG" {
  name                = "eastNSG"
  location            = azurerm_resource_group.eastcoast-rg.location
  resource_group_name = azurerm_resource_group.eastcoast-rg.name

  security_rule {
    name                       = "allowWeb"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allowRDP"
    priority                   = 105
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}


resource "azurerm_subnet_network_security_group_association" "eastAssociateNSG_backend" {
    subnet_id                   = azurerm_subnet.be-sub.id
    network_security_group_id   = azurerm_network_security_group.eastNSG.id 
}

resource "azurerm_subnet_network_security_group_association" "eastAssociateNSG_frontend" {
    subnet_id                   = azurerm_subnet.fe-sub.id
    network_security_group_id   = azurerm_network_security_group.eastNSG.id 
}


resource "azurerm_public_ip" "balancer-pip" {
    name                         = "loadbalance-ip"
    location            = azurerm_resource_group.eastcoast-rg.location
    resource_group_name = azurerm_resource_group.eastcoast-rg.name
    sku                 = "Standard"
    allocation_method   = "Static"
}


