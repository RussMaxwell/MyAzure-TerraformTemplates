resource "azurerm_application_gateway" "appgw" {
  name                = "myAppGateway"
  resource_group_name = azurerm_resource_group.eastcoast-rg.name
  location            = azurerm_resource_group.eastcoast-rg.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "boston-gw-ip-configuration"
    subnet_id = azurerm_subnet.fe-sub.id
  }

  frontend_port {
    name = "boston-webPort"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "bostonFE-Config"
    public_ip_address_id = azurerm_public_ip.balancer-pip.id
  }

  backend_address_pool {
    name = "bostonPool"
  }

  backend_http_settings {
    name                  = "backend-HTTPsetting"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "boston-Listener"
    frontend_ip_configuration_name = "bostonFE-Config"
    frontend_port_name             = "boston-webPort"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "contosoRoutingRule"
    rule_type                  = "Basic"
    http_listener_name         = "boston-Listener"
    backend_address_pool_name  = "bostonPool"
    backend_http_settings_name = "backend-HTTPsetting"
    priority                   = 10
  }
}


resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "boston-association" {
  count = 2
  network_interface_id = azurerm_network_interface.bostonNic[count.index].id
  ip_configuration_name   = "bostonIPConfig-${count.index+1}"
  backend_address_pool_id = azurerm_application_gateway.appgw.backend_address_pool.*.id[0]
}




