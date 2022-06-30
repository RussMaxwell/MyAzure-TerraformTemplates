resource "azurerm_network_interface" "bostonNic" {
    count = 2
    name                 = "bostonNic-${count.index+1}"
    location             = azurerm_resource_group.eastcoast-rg.location
    resource_group_name  = azurerm_resource_group.eastcoast-rg.name
    enable_ip_forwarding = true

    ip_configuration {
    name                          = "bostonIPConfig-${count.index+1}"
    subnet_id                     = azurerm_subnet.be-sub.id
    private_ip_address_allocation = "Dynamic"
    }
}


resource "azurerm_windows_virtual_machine" "boston-vm" {
  count = 2
  name                  = "boston-vm${count.index+1}"
  location              = azurerm_resource_group.eastcoast-rg.location
  resource_group_name   = azurerm_resource_group.eastcoast-rg.name
  admin_username = var.username
  admin_password = var.vmPasswrd
  network_interface_ids = [azurerm_network_interface.bostonNic[count.index].id]
  size                  = "Standard_B2ms"

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  os_disk {
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}


resource "azurerm_virtual_machine_extension" "boston_vm_ext_install_iis" {
  count = 2
  name                       = "install_iis${count.index+1}-ext"
  virtual_machine_id         =  azurerm_windows_virtual_machine.boston-vm[count.index].id 
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.8"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
        "commandToExecute":"powershell -ExecutionPolicy Unrestricted New-NetFirewallRule -Display allowHTTP -Direction Inbound -LocalPort 80 -Protocol TCP -Action All; powershell -ExecutionPolicy Unrestricted Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature -IncludeManagementTools"
    }
SETTINGS
}
