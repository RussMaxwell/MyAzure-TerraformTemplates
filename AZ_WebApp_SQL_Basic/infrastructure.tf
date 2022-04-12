resource "azurerm_resource_group" "ContosoWeb-rg" {
    name     = "Contoso-Web-RG"
    location = "eastus"
}


resource "azurerm_virtual_network" "contoso-vnet" {
    name                = "${var.prefix-web}-vnet"
    location            = azurerm_resource_group.ContosoWeb-rg.location
    resource_group_name = azurerm_resource_group.ContosoWeb-rg.name
    address_space       = ["10.1.0.0/16"]

    tags = {
    environment = "Contoso-WebApp"
    }
}


resource "azurerm_subnet" "fe-subnet" {
    name                 = "FrontendSubnet"
    resource_group_name  = azurerm_resource_group.ContosoWeb-rg.name
    virtual_network_name = azurerm_virtual_network.contoso-vnet.name
    address_prefixes     = ["10.1.2.0/24"]
}


resource "azurerm_subnet" "be-subnet" {
    name                 = "BackendSubnet"
    resource_group_name  = azurerm_resource_group.ContosoWeb-rg.name
    virtual_network_name = azurerm_virtual_network.contoso-vnet.name
    address_prefixes       = ["10.1.3.0/24"]
}


resource "azurerm_network_security_group" "eastNSG" {
  name                = "eastNSG"
  location            = azurerm_resource_group.ContosoWeb-rg.location
  resource_group_name = azurerm_resource_group.ContosoWeb-rg.name

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


resource "azurerm_subnet_network_security_group_association" "associateFrontend" {
  subnet_id                 = azurerm_subnet.fe-subnet.id
  network_security_group_id = azurerm_network_security_group.eastNSG.id
}

resource "azurerm_subnet_network_security_group_association" "associateBackend" {
  subnet_id                 = azurerm_subnet.be-subnet.id
  network_security_group_id = azurerm_network_security_group.eastNSG.id
}