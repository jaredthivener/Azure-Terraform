variable "resource_group_name" {}

variable "location" {
  default = "eastus2"
}

output "name" {
  value = azurerm_resource_group.rg.name
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}
