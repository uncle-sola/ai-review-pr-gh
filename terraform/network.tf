resource "azurerm_resource_group" "rg" {
  name     = module.naming.convention["resource_group"]
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = module.naming.convention["virtual_network"]
  address_space       = ["10.12.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  // dns_servers = ["10.0.0.1", "10.0.0.2"]
}

resource "azurerm_subnet" "subnet" {
  name                 = module.naming.convention["subnet"]
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.12.1.0/24"]
}

resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
  name                  = "${module.naming.convention["virtual_network"]}-blob-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}
