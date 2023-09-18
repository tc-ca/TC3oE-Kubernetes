resource "azurerm_key_vault" "dev" {
  resource_group_name = data.azurerm_resource_group.main.name
  tags = data.azurerm_resource_group.main.tags
  tenant_id = data.azurerm_client_config.main.tenant_id
  location = "canadacentral"
  sku_name = "standard"
  name = "mydemokeyvault"
}

resource "azurerm_key_vault_access_policy" "me" {
  secret_permissions      = ["Get", "List", "Set", "Delete", "Purge"]
  certificate_permissions = ["Get", "List", "Create", "Delete", "Import", "Purge"]
  key_permissions         = ["Get", "List", "Create", "Delete", "Import", "Purge"]
  key_vault_id            = azurerm_key_vault.dev.id
  tenant_id               = azurerm_key_vault.dev.tenant_id
  object_id               = "555-555-555-5555" # cloud admins
}

resource "azurerm_key_vault_secret" "demo_staticsite_storagekey" {
  key_vault_id = azurerm_key_vault.dev.id
  name         = "storagekey"
  value        = azurerm_storage_account.dev.primary_access_key
  depends_on = [
    azurerm_key_vault_access_policy.me,
  ]
}

resource "azurerm_key_vault_access_policy" "dev_workload_read" {
  secret_permissions = ["Get"]
  key_vault_id       = azurerm_key_vault.dev.id
  tenant_id          = azurerm_key_vault.dev.tenant_id
  object_id          = azurerm_user_assigned_identity.dev.principal_id
}