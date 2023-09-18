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
}

variable "route_table_routes" {
  type = list(object({
    name                   = string
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
}

resource "azurerm_route" "main" {
  for_each               = { for route in var.route_table_routes : route.name => route }
  route_table_name       = azurerm_route_table.main.name
  resource_group_name    = azurerm_route_table.main.resource_group_name
  name                   = each.value.name
  address_prefix         = each.value.address_prefix
  next_hop_type          = each.value.next_hop_type
  next_hop_in_ip_address = each.value.next_hop_in_ip_address
}

resource "azurerm_subnet_route_table_association" "main" {
  route_table_id = azurerm_route_table.main.id
  subnet_id      = var.vnet_subnet_id
}
