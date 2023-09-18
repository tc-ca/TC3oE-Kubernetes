# RESOURCE
variable "key_vault_name" {
  type = string
}
resource "azurerm_key_vault" "main" {
  name                            = var.key_vault_name
  resource_group_name             = data.azurerm_resource_group.main.name
  tags                            = data.azurerm_resource_group.main.tags
  location                        = "canadacentral"
  sku_name                        = "standard"
  tenant_id                       = data.azurerm_client_config.main.tenant_id
  enabled_for_template_deployment = true
  enable_rbac_authorization       = true
}

# ACCESS
# https://learn.microsoft.com/en-us/azure/key-vault/general/rbac-guide?tabs=azure-cli#azure-built-in-roles-for-key-vault-data-plane-operations
resource "azurerm_role_assignment" "me_kv" {
  role_definition_name = "Key Vault Administrator"
  principal_id         = "555-555-55555-5555" # cloud admins
  scope                = azurerm_key_vault.main.id
}
resource "azurerm_role_assignment" "core_kv" {
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.core_workload.principal_id
  scope                = azurerm_key_vault.main.id
}


# SECRETS
resource "random_password" "argocd_server_secret" {
  length = 16
}

locals {
  kv_secrets = {
    "argocd-application-client-secret" = azuread_application_password.argocd.value
    "argocd-server-secret"             = random_password.argocd_server_secret.result
    # "argocd-personal-access-token" = set manually !!!
    # "cluster-ssl-cert" = set by iac-kubernetes/tls/update-all-envs.ps1
    # "cluster-ssl-key" = set by iac-kubernetes/tls/update-all-envs.ps1
  }
}
resource "azurerm_key_vault_secret" "secret" {
  for_each     = local.kv_secrets
  key_vault_id = azurerm_key_vault.main.id
  name         = each.key
  value        = each.value
  depends_on = [
    azurerm_role_assignment.me_kv,
  ]
}
