provider "azurerm" {
  features {}
}

//Create a Resource Group
resource "azurerm_resource_group" "resource_group" {
  name = "terraform-rg"
  location = "westus"
}

//Create a Storage Account
resource "azurerm_storage_account" "storage_account" {
  name = "terraformjaredt123"
  location = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  account_replication_type = "LRS"
  account_kind = "StorageV2"
  account_tier = "Standard"
  enable_https_traffic_only = true
}