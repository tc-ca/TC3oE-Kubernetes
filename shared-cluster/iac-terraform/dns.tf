data "azurerm_resource_group" "corehub" {
  provider = azurerm.SCEDCORE
  name     = "my-dns-resource-group"
}

# create private DNS zone so we can connect to our private cluster using a private DNS name
resource "azurerm_private_dns_zone" "main" {
  provider            = azurerm.SCEDCORE
  resource_group_name = data.azurerm_resource_group.corehub.name
  name                = "privatelink.canadacentral.azmk8s.io"
  tags                = data.azurerm_resource_group.corehub.tags
}