locals {
    Atlanta-location       = "eastus"
    Atlanta-resource-group = "Contoso-Atlanta-rg"
    prefix-Atlanta         = "Atlanta"
}

resource "azurerm_resource_group" "Atlanta-vnet-rg" {
    name     = local.Atlanta-resource-group
    location = local.Atlanta-location
}

resource "azurerm_virtual_network" "Atlanta-vnet" {
    name                = "Atlanta-vnet"
    location            = azurerm_resource_group.Atlanta-vnet-rg.location
    resource_group_name = azurerm_resource_group.Atlanta-vnet-rg.name
    address_space       = ["10.7.0.0/16"]

    tags = {
    environment = local.prefix-Atlanta
    }
}

resource "azurerm_subnet" "Atlanta-sub" {
    name                 = "default"
    resource_group_name  = azurerm_resource_group.Atlanta-vnet-rg.name
    virtual_network_name = azurerm_virtual_network.Atlanta-vnet.name
    address_prefixes     = ["10.7.0.0/24"]
}


resource "azurerm_network_interface" "Atlanta-nic" {
    name                 = "${local.prefix-Atlanta}-nic"
    location             = azurerm_resource_group.Atlanta-vnet-rg.location
    resource_group_name  = azurerm_resource_group.Atlanta-vnet-rg.name
    enable_ip_forwarding = true

    ip_configuration {
    name                          = local.prefix-Atlanta
    subnet_id                     = azurerm_subnet.Atlanta-sub.id
    private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_windows_virtual_machine" "Atlanta-vm" {
  name                  = "${local.prefix-Atlanta}-vm"
  location              = azurerm_resource_group.Atlanta-vnet-rg.location
  resource_group_name   = azurerm_resource_group.Atlanta-vnet-rg.name
  admin_username = var.username
  admin_password = var.vmPasswrd
  network_interface_ids = [azurerm_network_interface.Atlanta-nic.id]
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
    environment = local.prefix-Atlanta
    }
}
