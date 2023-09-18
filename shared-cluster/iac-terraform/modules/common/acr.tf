variable "container_registry_name" {
  type = string
}
resource "azurerm_container_registry" "main" {
  resource_group_name           = data.azurerm_resource_group.main.name
  tags                          = data.azurerm_resource_group.main.tags
  name                          = var.container_registry_name
  location                      = "canadacentral"
  sku                           = "Premium"
  public_network_access_enabled = true
  admin_enabled                 = true
  # network_rule_set = [
  #   {

  #     default_action = "Deny"
  #     ip_rule = [
  #       {
  #         action   = "Allow"
  #         ip_range = "555.555.555.555/32"
  #       },
  #     ]
  #     virtual_network = []
  #   }
  # ]
}
