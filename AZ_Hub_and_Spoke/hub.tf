locals {
    prefix-hub         = "hub"
    hub-location       = "eastus"
    hub-resource-group = "Contoso-hub-rg"
    shared-key         = "abc123"
}

resource "azurerm_resource_group" "hub-vnet-rg" {
    name     = local.hub-resource-group
    location = local.hub-location
}

resource "azurerm_virtual_network" "hub-vnet" {
    name                = "${local.prefix-hub}-vnet"
    location            = azurerm_resource_group.hub-vnet-rg.location
    resource_group_name = azurerm_resource_group.hub-vnet-rg.name
    address_space       = ["10.5.0.0/16"]

    tags = {
    environment = "hub-spoke"
    }
}

resource "azurerm_subnet" "hub-gateway-subnet" {
    name                 = "GatewaySubnet"
    resource_group_name  = azurerm_resource_group.hub-vnet-rg.name
    virtual_network_name = azurerm_virtual_network.hub-vnet.name
    address_prefixes     = ["10.5.1.0/24"]
}


resource "azurerm_subnet" "bastion-subnet" {
    name                 = "AzureBastionSubnet"
    resource_group_name  = azurerm_resource_group.hub-vnet-rg.name
    virtual_network_name = azurerm_virtual_network.hub-vnet.name
    address_prefixes       = ["10.5.3.0/26"]
}


resource "azurerm_subnet" "fwSubnet" {
    name                 = "AzureFirewallSubnet"
    resource_group_name  = azurerm_resource_group.hub-vnet-rg.name
    virtual_network_name = azurerm_virtual_network.hub-vnet.name
    address_prefixes       = ["10.5.2.0/26"]
}



#Azure Firewall and Rule
resource "azurerm_public_ip" "fwPubIP" {
  name                = "firewallPubIP"
  resource_group_name = azurerm_resource_group.hub-vnet-rg.name
  location            = azurerm_resource_group.hub-vnet-rg.location
  allocation_method   = "Static"
  sku = "Standard"  
}

resource "azurerm_firewall" "azfirewall" {
  name                = "ContosoFirewall"
  location            = azurerm_resource_group.hub-vnet-rg.location
  resource_group_name = azurerm_resource_group.hub-vnet-rg.name
  sku_name = "AZFW_VNet"
  sku_tier = "Standard"


  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.fwSubnet.id
    public_ip_address_id = azurerm_public_ip.fwPubIP.id
  }
}


resource "azurerm_firewall_application_rule_collection" "outbound_allowSpokeInternet" {
  name                = "allowSpokeOutboundInternet"
  azure_firewall_name = azurerm_firewall.azfirewall.name
  resource_group_name = azurerm_resource_group.hub-vnet-rg.name
  priority            = 101
  action              = "Allow"

  rule {
    name = "spokeInternetOut"

    source_addresses = [
      "10.6.0.0/16",
    ]

    target_fqdns = [
      "*.com",
    ]

    protocol {
      port = "443"
      type = "Https"
    }

    protocol {
      port = "80"
      type = "Http"
    }
  }
}


resource "azurerm_firewall_network_rule_collection" "onPrem2Spoke" {
  name                = "onPremises2Spoke"
  azure_firewall_name = azurerm_firewall.azfirewall.name
  resource_group_name = azurerm_resource_group.hub-vnet-rg.name
  priority            = 100
  action              = "Allow"

  rule {
    name = "allowOnPrem2Spokes"

    source_addresses = [
      "192.168.0.0/16",
    ]

    destination_ports = [
      "80",
    ]

    destination_addresses = [
     "10.6.0.0/16",
    ]

    protocols = [
      "TCP",
    ]
  }
}



resource "azurerm_route_table" "gw-RT" {
  name                          = "gwRT"
  location                      = azurerm_resource_group.hub-vnet-rg.location
  resource_group_name           = azurerm_resource_group.hub-vnet-rg.name
  disable_bgp_route_propagation = false

  route {
    name           = "spoke1-firewallRoute"
    address_prefix = "10.6.0.0/16"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.azfirewall.ip_configuration[0].private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "rtAssociateHub" {
    subnet_id = azurerm_subnet.hub-gateway-subnet.id
    route_table_id = azurerm_route_table.gw-RT.id
}



#Bastion Service
resource "azurerm_public_ip" "hub-bastion-pip" {
    name                = "hub-bastion1-pip"
    location            = azurerm_resource_group.hub-vnet-rg.location
    resource_group_name = azurerm_resource_group.hub-vnet-rg.name
    sku = "Standard"
    allocation_method = "Static"
}


resource "azurerm_bastion_host" "hub-bastion" {
  name                = "ContosoBastion"
  location            = azurerm_resource_group.hub-vnet-rg.location
  resource_group_name = azurerm_resource_group.hub-vnet-rg.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion-subnet.id
    public_ip_address_id = azurerm_public_ip.hub-bastion-pip.id
  }

  depends_on = [azurerm_firewall_network_rule_collection.onPrem2Spoke, azurerm_subnet_route_table_association.rtAssociateHub]
    
}




# Virtual Network Gateway
resource "azurerm_public_ip" "hub-vpn-gateway1-pip" {
    name                = "hub-vpn-gateway1-pip"
    location            = azurerm_resource_group.hub-vnet-rg.location
    resource_group_name = azurerm_resource_group.hub-vnet-rg.name
    allocation_method = "Dynamic"
}


resource "azurerm_virtual_network_gateway" "hub-vnet-gateway" {
    name                = "hub-vpn-gateway1"
    location            = azurerm_resource_group.hub-vnet-rg.location
    resource_group_name = azurerm_resource_group.hub-vnet-rg.name

    type     = "Vpn"
    vpn_type = "RouteBased"

    active_active = false
    enable_bgp    = false
    sku           = "Basic"

    ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.hub-vpn-gateway1-pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.hub-gateway-subnet.id
    }
    depends_on = [azurerm_bastion_host.hub-bastion, azurerm_subnet_route_table_association.rtAssociateHub]
}


resource "azurerm_virtual_network_gateway_connection" "hub-onprem-conn" {
    name                = "hub-onprem-conn"
    location            = azurerm_resource_group.hub-vnet-rg.location
    resource_group_name = azurerm_resource_group.hub-vnet-rg.name

    type           = "Vnet2Vnet"
    routing_weight = 1

    virtual_network_gateway_id      = azurerm_virtual_network_gateway.hub-vnet-gateway.id
    peer_virtual_network_gateway_id = azurerm_virtual_network_gateway.onprem-vpn-gateway.id

    shared_key = local.shared-key
}


