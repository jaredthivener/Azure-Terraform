provider "azurerm" {
  features {}
}

data "azurerm_client_config" "config" {

}

resource "random_integer" "id" {
  min = 0000
  max = 9999
}

//Create Resource Group 
resource "azurerm_resource_group" "rg" {
  name     = "rg-synapse"
  location = "eastus2"
}

//Create Storage Account - ADLSv2
resource "azurerm_storage_account" "storage" {
  name                = "synapse${random_integer.id.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  is_hns_enabled           = true
}

resource "azurerm_storage_data_lake_gen2_filesystem" "fs" {
  name               = "synapse"
  storage_account_id = azurerm_storage_account.storage.id
}

resource "azurerm_synapse_workspace" "synapse" {
  name                                 = "synapse-terraform"
  location                             = azurerm_resource_group.rg.location
  resource_group_name                  = azurerm_resource_group.rg.name
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.fs.id
  sql_administrator_login              = "sqladmin"
  sql_administrator_login_password     = "TitM6Y9CL76*"

  identity {
    type = "SystemAssigned"
  }

  managed_resource_group_name = "rg-mng-synapse"

  aad_admin {
    login     = "AzureAD Admin"
    object_id = data.azurerm_client_config.config.object_id
    tenant_id = data.azurerm_client_config.config.tenant_id
  }
}

