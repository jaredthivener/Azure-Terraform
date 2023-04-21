provider "azurerm" {
  features {}
}

resource "random_integer" "id" {
  min = 0000
  max = 9999
}

resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
  tags = {
    Environment = "dev"
  }
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = var.cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.cluster_name

  default_node_pool {
    name       = "system"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "dev"
  }
}

resource "azurerm_storage_account" "storage" {
  name                     = "stg${random_integer.id.result}"
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_kind             = "StorageV2"
  account_replication_type = "LRS"

  tags = {
    Environment = "dev"
  }
}
