variable "cluster_core_workload_user_assigned_identity_name" {
  type = string
}
resource "azurerm_user_assigned_identity" "core_workload" {
  resource_group_name = data.azurerm_resource_group.main.name
  location            = "canadacentral"
  name                = var.cluster_core_workload_user_assigned_identity_name
  tags                = data.azurerm_resource_group.main.tags
}

variable "cluster_core_workload_namespace_service_account_names" {
  type = map(string)
}
resource "azurerm_federated_identity_credential" "core_workload" {
  for_each            = var.cluster_core_workload_namespace_service_account_names
  resource_group_name = data.azurerm_resource_group.main.name
  parent_id           = azurerm_user_assigned_identity.core_workload.id
  name                = "fedcred-${each.key}"
  issuer              = azurerm_kubernetes_cluster.main.oidc_issuer_url
  subject             = "system:serviceaccount:${each.key}:${each.value}"
  audience            = ["api://AzureADTokenExchange"]
}
