terraform {
  required_version = ">=1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }

  }
}

provider "azurerm" {
  features {
  }

  subscription_id = ""
  tenant_id       = ""
  alias           = "dlzsub"
}

provider "azurerm" {
  features {
  }

  subscription_id = ""
  tenant_id       = ""
  alias           = "dmlzsub"
}

data "azuread_group" "datagroup" {
object_id = ""
}


data "azurerm_resource_group" "dmlzrg" {
    provider = azurerm.dmlzsub
  for_each = toset(var.dmlz_resource_group_name)
  name = each.value
}

data "azurerm_resource_group" "dlzrg" {
    provider = azurerm.dlzsub
  for_each = toset(var.dlz_resource_group_name)
  name = each.value
}

resource "azurerm_role_assignment" "dmlzas" {
    provider = azurerm.dmlzsub
 for_each = data.azurerm_resource_group.dmlzrg
 scope = each.value.id
 role_definition_name = "Contributor"
 principal_id = data.azuread_group.datagroup.object_id
}

resource "azurerm_role_assignment" "dlzas" {
    provider = azurerm.dlzsub
 for_each = data.azurerm_resource_group.dlzrg
 scope = each.value.id
 role_definition_name = "Contributor"
 principal_id = data.azuread_group.datagroup.object_id
}
