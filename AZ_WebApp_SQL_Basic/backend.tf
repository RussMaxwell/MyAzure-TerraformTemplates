resource "azurerm_mssql_server" "ContosoSQL" {
  name                         = var.sqlservername
  resource_group_name          = azurerm_resource_group.ContosoWeb-rg.name
  location                     = azurerm_resource_group.ContosoWeb-rg.location
  version                      = "12.0"
  administrator_login          = "sqlAdmin"
  administrator_login_password = var.psswrd
}


resource "azurerm_mssql_firewall_rule" "clientRule" {
  name                = "clientFW"
  server_id           =  azurerm_mssql_server.ContosoSQL.id
  start_ip_address    = var.clientIP
  end_ip_address      = var.clientIP
}


resource "azurerm_mssql_firewall_rule" "azserviceRule" {
  name                = "allowAZservices"
  server_id           =  azurerm_mssql_server.ContosoSQL.id
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}


resource "azurerm_mssql_database" "ContosoDB" {
  name           = "ContosoDB"
  server_id      = azurerm_mssql_server.ContosoSQL.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = "1"
  sku_name       = "S1"
  zone_redundant = false

  tags = {
      environment = "Contoso-WebApp"
  }
}