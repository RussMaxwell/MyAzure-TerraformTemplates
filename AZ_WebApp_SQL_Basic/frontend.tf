resource "azurerm_service_plan" "Contoso-ServicePlan" {
  name                = "contosoASP"
  resource_group_name = azurerm_resource_group.ContosoWeb-rg.name
  location            = azurerm_resource_group.ContosoWeb-rg.location
  sku_name            = "B1"
  os_type             = "Linux"
}


resource "azurerm_linux_web_app" "Contoso-WebApp" {
  name                = var.webapp-name
  resource_group_name = azurerm_resource_group.ContosoWeb-rg.name
  location            = azurerm_service_plan.Contoso-ServicePlan.location
  service_plan_id     = azurerm_service_plan.Contoso-ServicePlan.id

  identity {
      type = "SystemAssigned"
  }

  site_config {
      
      application_stack {
        dotnet_version = "6.0"
      }
    }

  connection_string {
    name           = "SQLConnectionSTR"
    type           = "SQLServer"
    value          =  "Server=tcp:${azurerm_mssql_server.ContosoSQL.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.ContosoDB.name};Persist Security Info=False;User ID=${azurerm_mssql_server.ContosoSQL.administrator_login};Password=${azurerm_mssql_server.ContosoSQL.administrator_login_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  }
}