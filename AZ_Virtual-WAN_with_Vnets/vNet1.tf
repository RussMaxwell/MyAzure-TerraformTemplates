locals {
    boston-location       = "eastus"
    boston-resource-group = "Contoso-Boston-rg"
    prefix-boston         = "Boston"
}

resource "azurerm_resource_group" "boston-vnet-rg" {
    name     = local.boston-resource-group
    location = local.boston-location
}

resource "azurerm_virtual_network" "boston-vnet" {
    name                = "boston-vnet"
    location            = azurerm_resource_group.boston-vnet-rg.location
    resource_group_name = azurerm_resource_group.boston-vnet-rg.name
    address_space       = ["10.6.0.0/16"]

    tags = {
    environment = local.prefix-boston
    }
}


resource "azurerm_subnet" "boston-sub" {
    name                 = "default"
    resource_group_name  = azurerm_resource_group.boston-vnet-rg.name
    virtual_network_name = azurerm_virtual_network.boston-vnet.name
    address_prefixes     = ["10.6.0.0/24"]
}



resource "azurerm_public_ip" "boston-pip" {
    name                         = "${local.prefix-boston}-pip"
    location            = azurerm_resource_group.boston-vnet-rg.location
    resource_group_name = azurerm_resource_group.boston-vnet-rg.name
    allocation_method   = "Dynamic"

    tags = {
        environment = local.prefix-boston
    }
}


resource "azurerm_network_interface" "boston-nic" {
    name                 = "${local.prefix-boston}-nic"
    location             = azurerm_resource_group.boston-vnet-rg.location
    resource_group_name  = azurerm_resource_group.boston-vnet-rg.name
    enable_ip_forwarding = true

    ip_configuration {
    name                          = local.prefix-boston
    subnet_id                     = azurerm_subnet.boston-sub.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.boston-pip.id
    }
}


resource "azurerm_windows_virtual_machine" "boston-vm" {
  name                  = "${local.prefix-boston}-vm"
  location              = azurerm_resource_group.boston-vnet-rg.location
  resource_group_name   = azurerm_resource_group.boston-vnet-rg.name
  admin_username = var.username
  admin_password = var.vmPasswrd
  network_interface_ids = [azurerm_network_interface.boston-nic.id]
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
    environment = local.prefix-boston
    }
}
