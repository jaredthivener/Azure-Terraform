provider "azurerm" {
  features {}
}

//Create Resource Group 
resource "azurerm_resource_group" "rg" {
  name     = "terraform-vm"
  location = "eastus2"
  tags = {
    environment = "dev"
  }
}

//Create virtual Network 
resource "azurerm_virtual_network" "vn" {
  name                = "terraform-network"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "dev"
  }
}

//Create Subnet 
resource "azurerm_subnet" "subnet" {
  name                 = "terraform-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vn.name
  address_prefixes     = ["10.0.0.0/24"]
}

//Create Network Security Group
resource "azurerm_network_security_group" "nsg" {
  name                = "terraform-nsg"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  tags = {
    environment = "dev"
  }
}

//Create Network Security Group - Rule
resource "azurerm_network_security_rule" "terraform-dev-rule" {
  name                        = "ssh"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  source_address_prefix       = "*"
  destination_port_range      = "22"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

//Network Security Group Subnet Association
resource "azurerm_subnet_network_security_group_association" "mtc-nsg-association" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

//Create Public IP Address - Dynamic
resource "azurerm_public_ip" "terraform-ip" {
  name                = "terraform-ip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "dev"
  }
}

//Create Network Interface & Attach Public IP 
resource "azurerm_network_interface" "terraform-nic" {
  name                          = "terraform-nic"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "interal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"

    public_ip_address_id = azurerm_public_ip.terraform-ip.id
  }

  tags = {
    environment = "dev"
  }
}

//Create Linux VM
resource "azurerm_linux_virtual_machine" "terraform-vm" {
  name                = "terraform-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_D2_v4"
  admin_username      = "azureadmin"
  network_interface_ids = [
    azurerm_network_interface.terraform-nic.id,
  ]

  custom_data = filebase64("/mnt/c/Users/Jared/Downloads/Azure-Terraform/Linux-Dev-VM/customdata.tpl")

  admin_ssh_key {
    username   = "azureadmin"
    public_key = file("/home/jared/.ssh/id_rsa.pub")
  }

  os_disk {
    name                 = "terraform-vm-osDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  provisioner "local-exec" {
    command = templatefile("${var.host_os}-ssh-script.tpl", {
      hostname     = self.public_ip_address,
      user         = "azureadmin",
      identityfile = "/home/jared/.ssh/id_rsa"
    })
    interpreter = ["bash", "-c"]
  }

  tags = {
    environment = "dev"
  }
}

data "azurerm_public_ip" "terraform-ip-data" {
  name                = azurerm_public_ip.terraform-ip.name
  resource_group_name = azurerm_resource_group.rg.name
}

output "public_ip_address" {
  value = azurerm_linux_virtual_machine.terraform-vm.public_ip_address
}
