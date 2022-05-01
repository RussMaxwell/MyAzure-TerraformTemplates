locals {
    spoke1-location       = "eastus"
    spoke1-resource-group = "Contoso-Spoke-rg"
    prefix-spoke1         = "spoke1"
}

resource "azurerm_resource_group" "spoke1-vnet-rg" {
    name     = local.spoke1-resource-group
    location = local.spoke1-location
}

resource "azurerm_virtual_network" "spoke1-vnet" {
    name                = "spoke1-vnet"
    location            = azurerm_resource_group.spoke1-vnet-rg.location
    resource_group_name = azurerm_resource_group.spoke1-vnet-rg.name
    address_space       = ["10.6.0.0/16"]

    tags = {
    environment = local.prefix-spoke1
    }
}

resource "azurerm_subnet" "spoke1-sub" {
    name                 = "default"
    resource_group_name  = azurerm_resource_group.spoke1-vnet-rg.name
    virtual_network_name = azurerm_virtual_network.spoke1-vnet.name
    address_prefixes     = ["10.6.0.0/24"]
}


resource "azurerm_route_table" "spoke1-RT" {
  name                          = "spoke1RT"
  location                      = azurerm_resource_group.spoke1-vnet-rg.location
  resource_group_name           = azurerm_resource_group.spoke1-vnet-rg.name
  disable_bgp_route_propagation = true

  route {
    name           = "firewallRoute"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.azfirewall.ip_configuration[0].private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "rtAssociate1" {
    subnet_id = azurerm_subnet.spoke1-sub.id
    route_table_id = azurerm_route_table.spoke1-RT.id
}



resource "azurerm_network_interface" "spoke1-nic" {
    name                 = "${local.prefix-spoke1}-nic"
    location             = azurerm_resource_group.spoke1-vnet-rg.location
    resource_group_name  = azurerm_resource_group.spoke1-vnet-rg.name
    enable_ip_forwarding = true

    ip_configuration {
    name                          = local.prefix-spoke1
    subnet_id                     = azurerm_subnet.spoke1-sub.id
    private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_windows_virtual_machine" "spoke1-vm" {
  name                  = "${local.prefix-spoke1}-vm"
  location              = azurerm_resource_group.spoke1-vnet-rg.location
  resource_group_name   = azurerm_resource_group.spoke1-vnet-rg.name
  admin_username = var.username
  admin_password = var.vmPasswrd
  network_interface_ids = [azurerm_network_interface.spoke1-nic.id]
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

  tags = {
    environment = local.prefix-spoke1
    }


}


resource "azurerm_virtual_machine_extension" "vm_ext_install_iis" {
  name                       = "vm_extension_install_iis"
  virtual_machine_id         = azurerm_windows_virtual_machine.spoke1-vm.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.8"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell -ExecutionPolicy Unrestricted Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature -IncludeManagementTools"
    }
SETTINGS

depends_on = [azurerm_virtual_network_peering.hub-spoke1-peer]
}



resource "azurerm_virtual_network_peering" "spoke1-hub-peer" {
    name                      = "spoke1-hub-peer"
    resource_group_name       = azurerm_resource_group.spoke1-vnet-rg.name
    virtual_network_name      = azurerm_virtual_network.spoke1-vnet.name
    remote_virtual_network_id = azurerm_virtual_network.hub-vnet.id

    allow_virtual_network_access = true
    allow_forwarded_traffic = true
    allow_gateway_transit   = false
    use_remote_gateways     = true
    depends_on = [azurerm_virtual_network.spoke1-vnet, azurerm_virtual_network.hub-vnet , azurerm_virtual_network_gateway.hub-vnet-gateway]
}


resource "azurerm_virtual_network_peering" "hub-spoke1-peer" {
    name                      = "hub-spoke1-peer"
    resource_group_name       = azurerm_resource_group.hub-vnet-rg.name
    virtual_network_name      = azurerm_virtual_network.hub-vnet.name
    remote_virtual_network_id = azurerm_virtual_network.spoke1-vnet.id
    allow_virtual_network_access = true
    allow_forwarded_traffic   = true
    allow_gateway_transit     = true
    use_remote_gateways       = false
    depends_on = [azurerm_virtual_network.spoke1-vnet, azurerm_virtual_network.hub-vnet, azurerm_virtual_network_gateway.hub-vnet-gateway]
}