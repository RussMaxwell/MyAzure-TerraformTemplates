locals {
    onprem-location       = "eastus"
    onprem-resource-group = "Contoso-onprem-rg"
    prefix-onprem         = "onprem"
}

resource "azurerm_resource_group" "onprem-vnet-rg" {
    name     = local.onprem-resource-group
    location = local.onprem-location
}

resource "azurerm_virtual_network" "onprem-vnet" {
    name                = "onprem-vnet"
    location            = azurerm_resource_group.onprem-vnet-rg.location
    resource_group_name = azurerm_resource_group.onprem-vnet-rg.name
    address_space       = ["192.168.0.0/16"]

    tags = {
    environment = local.prefix-onprem
    }
}

resource "azurerm_subnet" "onprem-mgmt" {
    name                 = "default"
    resource_group_name  = azurerm_resource_group.onprem-vnet-rg.name
    virtual_network_name = azurerm_virtual_network.onprem-vnet.name
    address_prefixes     = ["192.168.1.0/24"]
}


resource "azurerm_subnet" "onprem-gateway-subnet" {
    name                 = "GatewaySubnet"
    resource_group_name  = azurerm_resource_group.onprem-vnet-rg.name
    virtual_network_name = azurerm_virtual_network.onprem-vnet.name
    address_prefixes     = ["192.168.2.0/24"]
}


resource "azurerm_public_ip" "onprem-pip" {
    name                         = "${local.prefix-onprem}-pip"
    location            = azurerm_resource_group.onprem-vnet-rg.location
    resource_group_name = azurerm_resource_group.onprem-vnet-rg.name
    allocation_method   = "Dynamic"

    tags = {
        environment = local.prefix-onprem
    }
}

resource "azurerm_network_interface" "onprem-nic" {
    name                 = "${local.prefix-onprem}-nic"
    location             = azurerm_resource_group.onprem-vnet-rg.location
    resource_group_name  = azurerm_resource_group.onprem-vnet-rg.name
    enable_ip_forwarding = true

    ip_configuration {
    name                          = local.prefix-onprem
    subnet_id                     = azurerm_subnet.onprem-mgmt.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.onprem-pip.id
    }
}




resource "azurerm_windows_virtual_machine" "onprem-vm" {
  name                  = "${local.prefix-onprem}-vm"
  location              = azurerm_resource_group.onprem-vnet-rg.location
  resource_group_name   = azurerm_resource_group.onprem-vnet-rg.name
  admin_username = var.username
  admin_password = var.vmPasswrd
  network_interface_ids = [azurerm_network_interface.onprem-nic.id]
  size                  = "Standard_DS1_v2"
 

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  os_disk {
    name              = "osdisk1"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}


resource "azurerm_public_ip" "onprem-vpn-gateway1-pip" {
    name                = "${local.prefix-onprem}-vpn-gateway1-pip"
    location            = azurerm_resource_group.onprem-vnet-rg.location
    resource_group_name = azurerm_resource_group.onprem-vnet-rg.name

    allocation_method = "Dynamic"
}


resource "azurerm_virtual_network_gateway" "onprem-vpn-gateway" {
    name                = "onprem-vpn-gateway1"
    location            = azurerm_resource_group.onprem-vnet-rg.location
    resource_group_name = azurerm_resource_group.onprem-vnet-rg.name

    type     = "Vpn"
    vpn_type = "RouteBased"

    active_active = false
    enable_bgp    = false
    sku           = "Basic"

    ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.onprem-vpn-gateway1-pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.onprem-gateway-subnet.id
    }
    depends_on = [azurerm_public_ip.onprem-vpn-gateway1-pip, azurerm_bastion_host.hub-bastion]

}

resource "azurerm_virtual_network_gateway_connection" "onprem-hub-conn" {
    name                = "onprem-hub-conn"
    location            = azurerm_resource_group.onprem-vnet-rg.location
    resource_group_name = azurerm_resource_group.onprem-vnet-rg.name
    type                            = "Vnet2Vnet"
    routing_weight = 1
    virtual_network_gateway_id      = azurerm_virtual_network_gateway.onprem-vpn-gateway.id
    peer_virtual_network_gateway_id = azurerm_virtual_network_gateway.hub-vnet-gateway.id

    shared_key = local.shared-key
}