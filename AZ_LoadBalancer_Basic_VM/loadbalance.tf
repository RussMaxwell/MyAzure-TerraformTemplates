resource "azurerm_lb" "Contoso-LB" {
  name                = "ContosoLoadBalancer"
  location            = azurerm_resource_group.eastcoast-rg.location
  resource_group_name = azurerm_resource_group.eastcoast-rg.name
  
  frontend_ip_configuration {
    name                 = "lbPublicIP"
    public_ip_address_id = azurerm_public_ip.balancer-pip.id
  }
}


resource "azurerm_lb_backend_address_pool" "backendPool" {
  loadbalancer_id = azurerm_lb.Contoso-LB.id
  name            = "BackendPool"
}


resource "azurerm_network_interface_backend_address_pool_association" "bostonAssociation" {
  network_interface_id    = azurerm_network_interface.boston-nic.id
  ip_configuration_name   = "bostonIP-Config"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backendPool.id
}


resource "azurerm_network_interface_backend_address_pool_association" "atlantaAssociation" {
  network_interface_id    = azurerm_network_interface.atlanta-nic.id
  ip_configuration_name   = "atlantaIP-Config"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backendPool.id
}


resource "azurerm_lb_probe" "contoso_lb_prob" {
  name                = "tcp-prob"
  protocol            = "Tcp"
  port                = 80
  loadbalancer_id     = azurerm_lb.Contoso-LB.id
}


resource "azurerm_lb_rule" "contoso_lb_rule_webapp" {
  name                           = "web-app-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = azurerm_lb.Contoso-LB.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backendPool.id]
  probe_id                       = azurerm_lb_probe.contoso_lb_prob.id
  loadbalancer_id                = azurerm_lb.Contoso-LB.id
}


resource "azurerm_lb_nat_rule" "bostonRDPAccess" {
  resource_group_name            = azurerm_resource_group.eastcoast-rg.name
  loadbalancer_id                = azurerm_lb.Contoso-LB.id
  name                           = "Boston-VM-RDPAccess"
  protocol                       = "Tcp"
  frontend_port                  = 45100
  backend_port                   = 3389
  frontend_ip_configuration_name = "lbPublicIP"
}


resource "azurerm_lb_nat_rule" "atlantaRDPAccess" {
  resource_group_name            = azurerm_resource_group.eastcoast-rg.name
  loadbalancer_id                = azurerm_lb.Contoso-LB.id
  name                           = "Atlanta-VM-RDPAccess"
  protocol                       = "Tcp"
  frontend_port                  = 45200
  backend_port                   = 3389
  frontend_ip_configuration_name = "lbPublicIP"
}


resource "azurerm_network_interface_nat_rule_association" "associate-natRule-boston" {
  network_interface_id  = azurerm_network_interface.boston-nic.id
  ip_configuration_name = "bostonIP-Config"
  nat_rule_id           = azurerm_lb_nat_rule.bostonRDPAccess.id
}


resource "azurerm_network_interface_nat_rule_association" "associate-natRule-atlanta" {
  network_interface_id  = azurerm_network_interface.atlanta-nic.id
  ip_configuration_name = "atlantaIP-Config"
  nat_rule_id           = azurerm_lb_nat_rule.atlantaRDPAccess.id
}

