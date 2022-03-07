//Azure Source and Provider we are specifying
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.98.0"
    }
  }
}

provider "azurerm" {
  features {}
}

//Create Resource Group 
resource "azurerm_resource_group" "mtc-rg" {
  name     = "mtc-resources"
  location = "West US"
  tags = {
    environment = "dev"
  }
}

//Create virtual Network 
resource "azurerm_virtual_network" "mtc-vn" {
  name                = "mtc-network"
  resource_group_name = azurerm_resource_group.mtc-rg.name
  location            = azurerm_resource_group.mtc-rg.location
  address_space       = ["10.123.0.0/16"]

  tags = {
    environment = "dev"
  }
}

//Create Subnet 
resource "azurerm_subnet" "mtc-subnet" {
  name                 = "mtc-subnet"
  resource_group_name  = azurerm_resource_group.mtc-rg.name
  virtual_network_name = azurerm_virtual_network.mtc-vn.name
  address_prefixes     = ["10.123.1.0/24"]
}

//Create Network Security Group
resource "azurerm_network_security_group" "mtc-nsg" {
  name                = "mtc-nsg"
  resource_group_name = azurerm_resource_group.mtc-rg.name
  location            = azurerm_resource_group.mtc-rg.location

  tags = {
    environment = "dev"
  }
}

//Create Network Security Group - Rule
resource "azurerm_network_security_rule" "mtc-dev-rule" {
  name                        = "mtc-dev-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  source_address_prefix       = "*"
  destination_port_range      = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.mtc-rg.name
  network_security_group_name = azurerm_network_security_group.mtc-nsg.name
}

//Network Security Group Subnet Association
resource "azurerm_subnet_network_security_group_association" "mtc-nsg-association" {
  subnet_id                 = azurerm_subnet.mtc-subnet.id
  network_security_group_id = azurerm_network_security_group.mtc-nsg.id
}

//Create Public IP Address - Dynamic
resource "azurerm_public_ip" "mtc-ip" {
  name                = "mtc-ip"
  resource_group_name = azurerm_resource_group.mtc-rg.name
  location            = azurerm_resource_group.mtc-rg.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "dev"
  }
}

//Create Network Interface & Attach Public IP 
resource "azurerm_network_interface" "mtc-nic" {
  name                = "mtc-nic"
  location            = azurerm_resource_group.mtc-rg.location
  resource_group_name = azurerm_resource_group.mtc-rg.name

  ip_configuration {
    name                          = "interal"
    subnet_id                     = azurerm_subnet.mtc-subnet.id
    private_ip_address_allocation = "Dynamic"

    public_ip_address_id = azurerm_public_ip.mtc-ip.id
  }

  tags = {
    environment = "dev"
  }
}

//Create Linux VM
resource "azurerm_linux_virtual_machine" "mtc-vm" {
  name                = "mtc-vm"
  resource_group_name = azurerm_resource_group.mtc-rg.name
  location            = azurerm_resource_group.mtc-rg.location
  size                = "Standard_B1s"
  admin_username      = "azureadmin"
  network_interface_ids = [
    azurerm_network_interface.mtc-nic.id,
  ]

  custom_data = filebase64("/Users/jared/Downloads/customdata.tpl")

  admin_ssh_key {
    username   = "azureadmin"
    public_key = file("/Users/jared/.ssh/mtcazurekey.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  provisioner "local-exec" {
    command = templatefile("${var.host_os}-ssh-script.tpl", {
      hostname     = self.public_ip_address,
      user         = "azureadmin",
      identityfile = "/Users/jared/.ssh/mtcazurekey"
    })
    interpreter = ["bash", "-c"]
  }

  tags = {
    environment = "dev"
  }
}

data "azurerm_public_ip" "mtc-ip-data" {
  name                = azurerm_public_ip.mtc-ip.name
  resource_group_name = azurerm_resource_group.mtc-rg.name
}

output "public_ip_address" {
  value = "${azurerm_linux_virtual_machine.mtc-vm.name}: ${data.azurerm_public_ip.mtc-ip-data.ip_address}"
}
