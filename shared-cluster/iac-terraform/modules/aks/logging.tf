variable "log_analytics_workspace_name" {
  type = string
}
resource "azurerm_log_analytics_workspace" "main" {
  resource_group_name = data.azurerm_resource_group.main.name
  name                = var.log_analytics_workspace_name
  tags                = data.azurerm_resource_group.main.tags
  location            = "canadacentral"
  daily_quota_gb      = 3
  retention_in_days   = 90
}