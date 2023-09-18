# https://stackoverflow.com/questions/69719271/azure-kubernetes-rbac-role-for-namespace-isolation

# https://learn.microsoft.com/en-us/azure/aks/manage-azure-rbac#create-role-assignments-for-users-to-access-cluster
# resource "azurerm_role_assignment" "aks_client_access" {
#   # each client can have multiple namespaces, we need a flat dict to do for_each
#   for_each = merge([
#     for client_key, client in local.clients : {
#       for namespace in client.namespaces : "${client_key}-${namespace}" => {
#         client    = client
#         namespace = namespace
#       }
#     }
#   ]...)
#   principal_id         = each.value.client.security_group_id
#   role_definition_name = "Azure Kubernetes Service RBAC Reader"
#   scope                = "${azurerm_kubernetes_cluster.main.id}/namespaces/${each.value.namespace}"
# }

variable "projects" {
  type = map(object({
    security_group_id = string # this module only cares about security groups
  }))
}

# https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#azure-kubernetes-service-cluster-user-role
resource "azurerm_role_assignment" "aks_client_connection" {
  # some projects share the security group id
  # this will flatten it so we only create one role assignment per security group
  for_each             = toset([for project in var.projects : project.security_group_id])
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = each.value
  scope                = azurerm_kubernetes_cluster.main.id
}
