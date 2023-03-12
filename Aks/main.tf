provider "azurerm" {
  features {}
}

module "resource_group" {
  source              = "./modules/resource-group"
  resource_group_name = "my-aks-rg"
  location            = "eastus2"
}

module "aks_cluster" {
  source              = "./modules/aks-cluster"
  resource_group_name = module.resource_group.name
  cluster_name        = "my-aks-cluster"
}
