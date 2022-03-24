variable "subscriptionID" {
    type=string
    default = "<enter your SubscriptionID here>"
}

variable "tenantID" {
    type=string
    default = "<enter your tenantID here>"
}
 
variable "vmPasswrd" {
    type=string
    default="<Enter password for VM Guest OS access>"
    #Important Note
    #The user account is: demousr
}


terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.99.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  subscription_id = var.subscriptionID
  tenant_id       = var.tenantID
  features {}
}


# Create a resource group in East US
resource "azurerm_resource_group" "ContosoEast" {
  name     = "ContosoEast"
  location = "East US"
}

# Create a resource group in West US
resource "azurerm_resource_group" "ContosoWest" {
  name     = "ContosoWest"
  location = "West US"
}


##########################
##Create VNET in East US##
##########################
resource "azurerm_virtual_network" "eastNet" {
  name                = "eastNet"
  address_space       = ["10.0.0.0/16"]
  location            = "East US"
  resource_group_name = azurerm_resource_group.ContosoEast.name  
}

resource "azurerm_network_security_group" "eastNSG" {
  name                = "eastNSG"
  location            = azurerm_resource_group.ContosoEast.location
  resource_group_name = azurerm_resource_group.ContosoEast.name

  security_rule {
    name                       = "allowRDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
 

resource "azurerm_subnet" "eastdefault" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.ContosoEast.name
  virtual_network_name = azurerm_virtual_network.eastNet.name
  address_prefixes     = ["10.0.0.0/24"]
}


resource "azurerm_subnet_network_security_group_association" "eastAssociateNSG" {
  subnet_id                 = azurerm_subnet.eastdefault.id
  network_security_group_id = azurerm_network_security_group.eastNSG.id
}


#build Pub IP resources for East 
resource "azurerm_public_ip" "eastPubIP" {
  name                = "contosoEastPubIP"
  resource_group_name = azurerm_resource_group.ContosoEast.name
  location            = azurerm_resource_group.ContosoEast.location
  allocation_method   = "Dynamic"  
}


resource "azurerm_network_interface" "eastinterface" {
  name                = "default-interface"
  location            = azurerm_virtual_network.eastNet.location
  resource_group_name = azurerm_resource_group.ContosoEast.name
 
  ip_configuration {
    name                          = "interfaceconfiguration"
    subnet_id                     = azurerm_subnet.eastdefault.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.eastPubIP.id
  }
}





##########################
##Create VNET in West US##
##########################
resource "azurerm_virtual_network" "westNet" {
  name                = "westNet"
  address_space       = ["10.5.0.0/16"]
  location            = "West US"
  resource_group_name = azurerm_resource_group.ContosoWest.name
  #depends_on = [azurerm_resource_group.grp]
}

resource "azurerm_network_security_group" "westNSG" {
  name                = "westNSG"
  location            = azurerm_resource_group.ContosoWest.location
  resource_group_name = azurerm_resource_group.ContosoWest.name

  security_rule {
    name                       = "allowRDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet" "westdefault" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.ContosoWest.name
  virtual_network_name = azurerm_virtual_network.westNet.name
  address_prefixes     = ["10.5.0.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "westAssociateNSG" {
  subnet_id                 = azurerm_subnet.westdefault.id
  network_security_group_id = azurerm_network_security_group.westNSG.id
}


#Create Public IP address in West US
resource "azurerm_public_ip" "westPubIP" {
  name                = "contosoWestPubIP"
  resource_group_name = azurerm_resource_group.ContosoWest.name
  location            = azurerm_resource_group.ContosoWest.location
  allocation_method   = "Dynamic"  
}
 
resource "azurerm_network_interface" "westinterface" {
  name                = "default-interface"
  location            = azurerm_virtual_network.westNet.location
  resource_group_name = azurerm_resource_group.ContosoWest.name
 
  ip_configuration {
    name                          = "interfaceconfiguration"
    subnet_id                     = azurerm_subnet.westdefault.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.westPubIP.id
  }
}


#Setup a Peering Connection between VNets
resource "azurerm_virtual_network_peering" "West2East" {
  name                      = "peerWest2East"
  resource_group_name       = azurerm_resource_group.ContosoWest.name
  virtual_network_name      = azurerm_virtual_network.westNet.name
  remote_virtual_network_id = azurerm_virtual_network.eastNet.id
}

resource "azurerm_virtual_network_peering" "East2West" {
  name                      = "peerEast2West"
  resource_group_name       = azurerm_resource_group.ContosoEast.name
  virtual_network_name      = azurerm_virtual_network.eastNet.name
  remote_virtual_network_id = azurerm_virtual_network.westNet.id
}



#Create Azure VM in East US
resource "azurerm_virtual_machine" "eastvm" {
  name                  = "contosoEastVM"
  location              = "East US"
  resource_group_name   = azurerm_resource_group.ContosoEast.name
  network_interface_ids = [azurerm_network_interface.eastinterface.id]
  vm_size               = "Standard_DS1_v2"
 
  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
  storage_os_disk {
    name              = "osdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "contosoeastvm"
    admin_username = "demousr"
    admin_password = var.vmPasswrd
  }
 
 os_profile_windows_config {}
}


#Create Azure VM in West US
resource "azurerm_virtual_machine" "westvm" {
  name                  = "contosoWestVM"
  location              = "West US"
  resource_group_name   = azurerm_resource_group.ContosoWest.name
  network_interface_ids = [azurerm_network_interface.westinterface.id]
  vm_size               = "Standard_DS1_v2"
 
  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
  storage_os_disk {
    name              = "osdisk2"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "contosowestvm"
    admin_username = "demousr"
    admin_password = var.vmPasswrd
  }

  os_profile_windows_config {}
  
}

