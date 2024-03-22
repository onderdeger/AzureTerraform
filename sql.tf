resource "azurerm_mssql_server" "azurerm_mssql_server" {
    provider = azurerm.genonnonprod
  name                         = "sql-general-online-test"
  resource_group_name          = azurerm_resource_group.db_rg.name
  location                     = var.location
  version                      = "12.0"
  public_network_access_enabled = false
azuread_administrator {
  azuread_authentication_only = true
   login_username = "Az_SQL_Admins"
  object_id = 	    data.azuread_group.datagroup.id
}
  minimum_tls_version = "1.2"
  tags = {
    environment = "dev"
  }
}

resource "azurerm_mssql_database" "azurerm_mssql_database" {
    provider = azurerm.genonnonprod
  name                = "sqldb-${local.prefix}"
server_id = azurerm_mssql_server.azurerm_mssql_server.id
  collation           = "SQL_Latin1_General_CP1_CI_AS"
  zone_redundant      = false
  read_scale          = false
  auto_pause_delay_in_minutes = 60
  create_mode         = "Default"
  sku_name = "GP_S_Gen5_2"
  max_size_gb = 32
  min_capacity = 0.5
  storage_account_type = "Local"
  tags = {
    environment = "dev"
  }
}

resource "azurerm_private_endpoint" "sql_private_enpoint" {
provider = azurerm.genonnonprod
name = "sql-general-online-test-pe"
location = var.location
resource_group_name = azurerm_resource_group.db_rg.name
custom_network_interface_name = "${azurerm_mssql_server.azurerm_mssql_server.name}-nic"

private_service_connection {
  name = "${azurerm_mssql_server.azurerm_mssql_server.name}-pe"
  is_manual_connection = false
  private_connection_resource_id = azurerm_mssql_server.azurerm_mssql_server.id
  subresource_names = ["sqlServer"]
}
subnet_id = azurerm_subnet.vnet-subnet02.id

dynamic "private_dns_zone_group" {
for_each = var.private_dns_zone_id_sql == "" ? [] : [1]
content {
  name = "${azurerm_mssql_server.azurerm_mssql_server.name}-arecord"
  private_dns_zone_ids = [var.private_dns_zone_id_sql]
}
}
}
