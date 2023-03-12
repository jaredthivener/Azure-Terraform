variable "resource_group_name" {}

variable "cluster_name" {}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = var.cluster_name
  location            = var.resource_group_name.location
  resource_group_name = var.resource_group_name.name
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
