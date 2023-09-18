variable "container_registry_private_endpoint_name" {
  type = string
}
variable "container_registry_id" {
  type = string
}

resource "azurerm_private_endpoint" "acr" {
  resource_group_name = data.azurerm_resource_group.main.name
  tags                = data.azurerm_resource_group.main.tags
  name                = var.container_registry_private_endpoint_name
  location            = "canadacentral"
  subnet_id           = var.vnet_subnet_id # from aks.tf

  private_service_connection {
    subresource_names              = ["registry"]
    is_manual_connection           = false
    name                           = var.container_registry_private_endpoint_name
    private_connection_resource_id = var.container_registry_id
  }
  lifecycle {
    ignore_changes = [private_dns_zone_group]
  }
}

# ensure cluster has permissions to pull from the registry
resource "azurerm_role_assignment" "acr" {
  principal_id         = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
  role_definition_name = "AcrPull"
  scope                = var.container_registry_id
}