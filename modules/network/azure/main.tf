resource "azurerm_virtual_network" "vnet" {
  name                = var.network_name
  location            = var.location
  resource_group_name = var.resource_group
  address_space       = var.address_space

  tags = {
    managed-by = "terraform"
  }
}

resource "azurerm_subnet" "subnet" {
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value.cidr]
}
