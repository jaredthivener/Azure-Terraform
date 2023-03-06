resource "random_integer" "id" {
  min = 0000
  max = 9999
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-terraform-aks"
  location = "eastus2"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "terraform-aks-${random_integer.id.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "terraform-aks-${random_integer.id.result}"

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