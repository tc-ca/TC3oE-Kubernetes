module "common_nprd" {
  source = "./modules/common"
  providers = {
    azurerm     = azurerm
    azuredevops = azuredevops
  }
  resource_group_name                               = "my-cluster-common-nprd-rg"
  projects                                          = var.projects
  container_registry_name                           = "mynprdcontainerregistry"
  container_registry_devops_service_connection_name = "clusterz-nprd-%s" # formatted with project name
}

locals {
  nprd_routes = [
    {
      name           = "AzureAD"
      address_prefix = "AzureActiveDirectory"
      next_hop_type  = "Internet"
    },
    {
      name           = "AzD"
      address_prefix = "AzureDevOps"
      next_hop_type  = "Internet"
    },
    {
      name                   = "Internet"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "555.555.555.555" # route through firewall
    }
  ]
}
module "dev-1" {
  source = "./modules/aks"
  providers = {
    azurerm      = azurerm
    azurerm.dns  = azurerm.SCEDCORE
    azurerm.vnet = azurerm.SCEDCORE
    azuread      = azuread
    azuredevops  = azuredevops
  }
  resource_group_name             = "my-cluster-dev-1-rg"
  aks_managed_resource_group_name = "MC_my-cluster-dev-1-rg"
  aks_name                        = "my-cluster-dev-1-aks"
  aks_admin_aad_group_name        = "my-cloud-admins-secgroup"
  argo_aad_app_name               = "my-cluster-dev-1-argo"
  argo_aad_app_owners             = data.azuread_group.cloudops.members

  vnet_subnet_id   = azurerm_subnet.dev-1.id
  vnet_id          = azurerm_virtual_network.k8s-nprd.id
  route_table_name = "my-cluster-dev-1-rt"
  route_table_routes = local.nprd_routes
  aks_private      = true

  argocd_hostname = "argocd.dev.cloud.org.gc.ca"

  cluster_user_assigned_identity_name               = "my-cluster-dev-1-aks-mi"
  cluster_core_workload_user_assigned_identity_name = "my-cluster-dev-1-aks-core-workloads-mi"
  cluster_core_workload_namespace_service_account_names = {
    # k8s namespace : k8s service account name
    "argocd"        = "my-workload-identity"
    "ingress-nginx" = "my-workload-identity"
  }
  key_vault_name                           = "my-cluster-dev-1-kv"
  log_analytics_workspace_name             = "my-cluster-dev-1-law"
  projects                                 = var.projects
  cluster_private_dns_zone_id              = azurerm_private_dns_zone.main.id
  container_registry_private_endpoint_name = "container-registry-pe"
  container_registry_id                    = module.common_nprd.container_registry_id

}