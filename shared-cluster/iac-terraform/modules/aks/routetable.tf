variable "route_table_name" {
  type = string
}

# There should be only one cluster per route table
# https://learn.microsoft.com/en-us/azure/aks/configure-kubenet#bring-your-own-subnet-and-route-table-with-kubenet
resource "azurerm_route_table" "main" {
  resource_group_name = data.azurerm_resource_group.main.name
  tags                = data.azurerm_resource_group.main.tags
  name                = var.route_table_name
  location            = "canadacentral"

  route {
    name           = "AzureAD"
    address_prefix = "AzureActiveDirectory"
    next_hop_type  = "Internet"
  }
  route {
    name           = "AzD"
    address_prefix = "AzureDevOps"
    next_hop_type  = "Internet"
  }
  route {
    name                   = "Internet"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "555.555.555.555" # route through firewall
  }

  lifecycle {
    ignore_changes = [route]
  }
}

resource "azurerm_subnet_route_table_association" "main" {
  route_table_id = azurerm_route_table.main.id
  subnet_id      = var.vnet_subnet_id
}
