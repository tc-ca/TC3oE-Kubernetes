variable "aks_admin_aad_group_name" {
  type = string
}
data "azuread_group" "admins" {
  display_name = var.aks_admin_aad_group_name
}

variable "cluster_private_dns_zone_id" {
  type = string
}
# https://learn.microsoft.com/en-us/azure/aks/private-clusters#configure-private-dns-zone
resource "azurerm_role_assignment" "dnscontrib" {
  provider             = azurerm.dns
  principal_id         = azurerm_user_assigned_identity.cluster.principal_id
  scope                = var.cluster_private_dns_zone_id
  role_definition_name = "Private DNS Zone Contributor"
}


variable "aks_name" {
  type = string
}
variable "aks_managed_resource_group_name" {
  type = string
}
variable "aks_private" {
  type = bool
}
variable "vnet_subnet_id" {
  type = string
}
variable "vnet_id" {
  type = string
}

resource "azurerm_kubernetes_cluster" "main" {
  resource_group_name = data.azurerm_resource_group.main.name
  tags                = data.azurerm_resource_group.main.tags
  node_resource_group = var.aks_managed_resource_group_name
  location            = "canadacentral"
  dns_prefix          = var.aks_name
  name                = var.aks_name
  kubernetes_version  = "1.25.6"


  private_cluster_enabled   = var.aks_private
  azure_policy_enabled      = true
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  private_dns_zone_id = var.cluster_private_dns_zone_id

  role_based_access_control_enabled = true

  network_profile {
    network_plugin = "kubenet"
  }


  azure_active_directory_role_based_access_control {
    managed            = true
    azure_rbac_enabled = true
    admin_group_object_ids = [
      data.azuread_group.admins.object_id
    ]
  }

  default_node_pool {
    name                        = "default"
    enable_auto_scaling         = true
    max_count                   = 4
    min_count                   = 1
    vm_size                     = "Standard_D2s_v3"
    vnet_subnet_id              = var.vnet_subnet_id
    zones                       = ["1", "2", "3"]
    orchestrator_version        = "1.25.6"
    temporary_name_for_rotation = "defaulttemp"
    # os_sku              = "AzureLinux"
    # AzureLinux not supported by Terraform yet 2023-06-08
    # https://github.com/hashicorp/terraform-provider-azurerm/issues/21931
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.cluster.id
    ]
  }

  oms_agent {
    log_analytics_workspace_id      = azurerm_log_analytics_workspace.main.id
    msi_auth_for_monitoring_enabled = true
  }
  depends_on = [
    azurerm_role_assignment.dnscontrib,
    azurerm_role_assignment.vnet,
    azurerm_role_assignment.rg,
    azurerm_route_table.main
  ]
}
