locals {
    subscriptionID     = "<addSubscriptionID>"
    tenantID           = "<tenantID>"
    vmPasswrd          = "<enterVMPassword>"
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
  name     = "ContosoEast"
  location = "East US"
}


resource "azurerm_virtual_network" "eastNet" {
  name                = "eastNet"
  address_space       = ["10.0.0.0/16"]
  location            = "East US"
  resource_group_name = azurerm_resource_group.ContosoEast.name  
}


resource "azurerm_subnet" "eastdefault" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.ContosoEast.name
  virtual_network_name = azurerm_virtual_network.eastNet.name
  address_prefixes     = ["10.0.0.0/24"]
}


resource "azurerm_subnet" "fwSubnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.ContosoEast.name
  virtual_network_name = azurerm_virtual_network.eastNet.name
  address_prefixes     = ["10.0.1.0/24"]
}


resource "azurerm_public_ip" "firewallPubIP" {
  name                = "contosoEastPubIP"
  resource_group_name = azurerm_resource_group.ContosoEast.name
  location            = azurerm_resource_group.ContosoEast.location
  allocation_method   = "Static"
  sku = "Standard"  
}


resource "azurerm_network_interface" "eastinterface" {
  name                = "default-interface"
  location            = azurerm_virtual_network.eastNet.location
  resource_group_name = azurerm_resource_group.ContosoEast.name
 
  ip_configuration {
    name                          = "interfaceconfiguration"
    subnet_id                     = azurerm_subnet.eastdefault.id
    private_ip_address_allocation = "Static"
    private_ip_address = "10.0.0.7"
  }
}


resource "azurerm_firewall" "azfirewall" {
  name                = "ContosoFirewall"
  location            = azurerm_resource_group.ContosoEast.location
  resource_group_name = azurerm_resource_group.ContosoEast.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.fwSubnet.id
    public_ip_address_id = azurerm_public_ip.firewallPubIP.id
  }
}


resource "azurerm_firewall_nat_rule_collection" "Inbound_allowRDP" {
  name                = "allowInboundRDP"
  azure_firewall_name = azurerm_firewall.azfirewall.name
  resource_group_name = azurerm_resource_group.ContosoEast.name
  priority            = 100
  action              = "Dnat"

  rule {
    name = "vmAccess"

    source_addresses = [
      "0.0.0.0/0",
    ]

    destination_ports = [
      "4000",
    ]

    destination_addresses = [
      azurerm_public_ip.firewallPubIP.ip_address
    ]

    translated_port = 3389

    translated_address = azurerm_windows_virtual_machine.vm.private_ip_address

    protocols = [
      "TCP",
    ]
  }
}


resource "azurerm_firewall_application_rule_collection" "outbound_allowInternet" {
  name                = "allowOutboundInternet"
  azure_firewall_name = azurerm_firewall.azfirewall.name
  resource_group_name = azurerm_resource_group.ContosoEast.name
  priority            = 100
  action              = "Allow"

  rule {
    name = "vmInternetOut"

    source_addresses = [
      "10.0.0.0/24",
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


resource "azurerm_route_table" "customRT" {
  name                          = "defaultRT"
  location                      = azurerm_resource_group.ContosoEast.location
  resource_group_name           = azurerm_resource_group.ContosoEast.name
  disable_bgp_route_propagation = false

  route {
    name           = "firewallRoute"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.azfirewall.ip_configuration[0].private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "rtAssociate" {
    subnet_id = azurerm_subnet.eastdefault.id
    route_table_id = azurerm_route_table.customRT.id
}


resource "azurerm_windows_virtual_machine" "vm" {
  name                  = "contosoEastVM"
  location              = "East US"
  resource_group_name   = azurerm_resource_group.ContosoEast.name
  admin_username = "demousr"
  admin_password = local.vmPasswrd
  network_interface_ids = [azurerm_network_interface.eastinterface.id]
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

  depends_on = [
    azurerm_firewall.azfirewall
  ]

}