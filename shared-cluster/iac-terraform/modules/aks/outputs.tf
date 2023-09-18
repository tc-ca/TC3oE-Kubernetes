output "argocd_application_id" {
  value = azuread_application.argocd.application_id
}

output "argocd_hostname" {
  value = var.argocd_hostname
}

output "tenant_id" {
  value = data.azurerm_client_config.main.tenant_id
}

# output "user_assigned_identity_principal_id" {
#   value = azurerm_user_assigned_identity.cluster.principal_id
# }

# output "kubelet_identity_client_id" {
#   value = azurerm_kubernetes_cluster.main.kubelet_identity[0].client_id
# }

output "core_workload_identity_client_id" {
  value = azurerm_user_assigned_identity.core_workload.client_id
}
output "key_vault_uri" {
  value = azurerm_key_vault.main.vault_uri
}
output "key_vault_id" {
  value = azurerm_key_vault.main.id
}

# output "aks_oidc_issuer_url" {
#   value = azurerm_kubernetes_cluster.main.oidc_issuer_url
# }