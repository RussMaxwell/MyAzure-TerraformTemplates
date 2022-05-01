resource "azurerm_availability_set" "contoso_availability_set" {
    name = "contoso_availability_set"
    location = azurerm_resource_group.eastcoast-rg.location
    resource_group_name = azurerm_resource_group.eastcoast-rg.name
}


resource "azurerm_windows_virtual_machine" "boston-vm" {
  name                  = "boston-vm"
  location              = azurerm_resource_group.eastcoast-rg.location
  resource_group_name   = azurerm_resource_group.eastcoast-rg.name
  admin_username = var.username
  admin_password = var.vmPasswrd
  network_interface_ids = [azurerm_network_interface.boston-nic.id]
  size                  = "Standard_B2ms"
  availability_set_id = azurerm_availability_set.contoso_availability_set.id

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


resource "azurerm_windows_virtual_machine" "atlanta-vm" {
  name                  = "atlanta-vm"
  location              = azurerm_resource_group.eastcoast-rg.location
  resource_group_name   = azurerm_resource_group.eastcoast-rg.name
  admin_username = var.username
  admin_password = var.vmPasswrd
  network_interface_ids = [azurerm_network_interface.atlanta-nic.id]
  size                  = "Standard_B2ms"
  availability_set_id = azurerm_availability_set.contoso_availability_set.id
 

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  os_disk {
    name              = "osdisk2"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}


resource "azurerm_virtual_machine_extension" "boston_vm_ext_install_iis" {
  name                       = "boston_vm_extension_install_iis"
  virtual_machine_id         =  azurerm_windows_virtual_machine.boston-vm.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.8"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
        "commandToExecute":"powershell -ExecutionPolicy Unrestricted New-NetFirewallRule -Display allowHTTP -Direction Inbound -LocalPort 80 -Protocol TCP -Action All; powershell -ExecutionPolicy Unrestricted Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature -IncludeManagementTools"
    }
SETTINGS
depends_on = [azurerm_windows_virtual_machine.atlanta-vm]
}


resource "azurerm_virtual_machine_extension" "atlanta_vm_ext_install_iis" {
  name                       = "atlanta_vm_extension_install_iis"
  virtual_machine_id         = azurerm_windows_virtual_machine.atlanta-vm.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.8"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell -ExecutionPolicy Unrestricted New-NetFirewallRule -Display allowHTTP -Direction Inbound -LocalPort 80 -Protocol TCP -Action All; powershell -ExecutionPolicy Unrestricted Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature -IncludeManagementTools"
    }
SETTINGS
depends_on = [azurerm_windows_virtual_machine.boston-vm]
}













