resource "azurerm_storage_account" "dev" {
  resource_group_name             = data.azurerm_resource_group.main.name
  tags                            = data.azurerm_resource_group.main.tags
  name                            = "mydemostorageaccount"
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  allow_nested_items_to_be_public = false
  location                        = "canadacentral"
}

resource "azurerm_storage_container" "dev" {
  name                 = "webcontent"
  storage_account_name = azurerm_storage_account.dev.name
}

resource "azurerm_role_assignment" "data_read" {
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_user_assigned_identity.dev.principal_id
  scope                = azurerm_storage_account.dev.id
}