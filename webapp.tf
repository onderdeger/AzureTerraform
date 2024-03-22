resource "azurerm_service_plan" "serplan01" {
  provider = azurerm.genonnonprod
  name = "asp-${local.prefix}"
  location = var.location
  resource_group_name = azurerm_resource_group.datahub_rg.name
  sku_name = "B1"
  os_type = "Windows"
}

resource "azurerm_windows_web_app" "datahub-webapp" {
  provider = azurerm.genonnonprod
  name = "app-${local.prefix}"
  location = var.location
  resource_group_name = azurerm_resource_group.datahub_rg.name
  service_plan_id = azurerm_service_plan.serplan01.id
  https_only = true
  public_network_access_enabled = false
  site_config {
    minimum_tls_version = "1.2"
  }
}



resource "azurerm_app_service_virtual_network_swift_connection" "app_network" {
  provider = azurerm.genonnonprod
  app_service_id = azurerm_windows_web_app.datahub-webapp.id
  subnet_id = azurerm_subnet.vnet-subnet03.id
}

resource "azurerm_private_endpoint" "app_private_enpoint" {
provider = azurerm.genonnonprod
name = "app-${local.prefix}-pe"
location = var.location
resource_group_name = azurerm_resource_group.datahub_rg.name
custom_network_interface_name = "${azurerm_windows_web_app.datahub-webapp.name}-nic"

private_service_connection {
  name = "${azurerm_windows_web_app.datahub-webapp.name}-pe"
  is_manual_connection = false
  private_connection_resource_id = azurerm_windows_web_app.datahub-webapp.id
  subresource_names = ["sites"]
}
subnet_id = azurerm_subnet.vnet-subnet01.id

dynamic "private_dns_zone_group" {
for_each = var.private_dns_zone_id_app == "" ? [] : [1]
content {
  name = "${azurerm_windows_web_app.datahub-webapp.name}-arecord"
  private_dns_zone_ids = [var.private_dns_zone_id_app]
}
}
}
