resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.resource_group_location

  tags = {
    environment = "azure-demo"
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  address_space       = ["10.42.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = {
    environment = "azure-demo"
  }
}

resource "azurerm_subnet" "linux-subnet" {
  name                 = "linux-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.42.5.0/24"]
}

resource "azurerm_subnet" "aks-subnet" {
  name                 = "linux-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.42.1.0/24"]
}

