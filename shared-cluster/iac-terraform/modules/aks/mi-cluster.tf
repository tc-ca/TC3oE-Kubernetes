variable "cluster_user_assigned_identity_name" {
  type = string
}
resource "azurerm_user_assigned_identity" "cluster" {
  resource_group_name = data.azurerm_resource_group.main.name
  location            = "canadacentral"
  name                = var.cluster_user_assigned_identity_name
  tags                = data.azurerm_resource_group.main.tags
}

# https://learn.microsoft.com/en-us/azure/aks/private-clusters#configure-private-dns-zone
resource "azurerm_role_assignment" "vnet" {
  provider             = azurerm.vnet
  principal_id         = azurerm_user_assigned_identity.cluster.principal_id
  scope                = var.vnet_id
  role_definition_name = "Network Contributor"
}

# https://learn.microsoft.com/en-us/azure/aks/private-clusters#configure-private-dns-zone
resource "azurerm_role_assignment" "rg" {
  principal_id         = azurerm_user_assigned_identity.cluster.principal_id
  role_definition_name = "Contributor"
  scope                = data.azurerm_resource_group.main.id
}