variable "projects" {
  type = map(object({ # this module only cares about a subset of project properties
    security_group_id   = string,
    devops_project_name = string,
    acr_image_names     = set(string)
  }))
}
locals {
  projects_with_images = {
    for name, project in var.projects :
    name => project
    if length(project.acr_image_names) > 0
  }
}
#####
## AZURE PORTAL - CLIENT ACR READER ACCESS
#####

resource "azurerm_role_assignment" "acr_read" {
  for_each             = local.projects_with_images
  principal_id         = each.value.security_group_id
  role_definition_name = "Reader"
  scope                = azurerm_container_registry.main.id
}

#####
## AZURE PORTAL - CLIENT ACR SCOPED TOKEN
#####

resource "azurerm_container_registry_scope_map" "main" {
  for_each                = local.projects_with_images
  container_registry_name = azurerm_container_registry.main.name
  resource_group_name     = azurerm_container_registry.main.resource_group_name
  name                    = each.key
  actions = flatten([
    for image in each.value.acr_image_names : [
      "repositories/${each.key}/${image}/content/write",
      "repositories/${each.key}/${image}/content/read",
    ]
  ])
  description = "For devops service connection"
}
resource "azurerm_container_registry_token" "main" {
  for_each                = local.projects_with_images
  resource_group_name     = azurerm_container_registry.main.resource_group_name
  container_registry_name = azurerm_container_registry.main.name
  scope_map_id            = azurerm_container_registry_scope_map.main[each.key].id
  name                    = each.key
}
resource "time_rotating" "token_expire" {
  for_each      = local.projects_with_images
  rotation_days = 30 * 6
}
resource "azurerm_container_registry_token_password" "main" {
  for_each                    = local.projects_with_images
  container_registry_token_id = azurerm_container_registry_token.main[each.key].id

  password1 {
    expiry = timeadd(time_rotating.token_expire[each.key].id, "${24 * time_rotating.token_expire[each.key].rotation_days}h")
  }
}

#####
## AZURE DEVOPS - CLIENT SERVICE CONNECTION USING SCOPED TOKEN
#####

data "azuredevops_project" "main" {
  for_each = local.projects_with_images
  name     = each.value.devops_project_name
}

variable "container_registry_devops_service_connection_name" {
  type = string
}
resource "azuredevops_serviceendpoint_dockerregistry" "main" {
  for_each              = local.projects_with_images
  project_id            = data.azuredevops_project.main[each.key].id
  service_endpoint_name = format(var.container_registry_devops_service_connection_name, each.key)
  docker_registry       = azurerm_container_registry.main.login_server
  docker_username       = azurerm_container_registry_scope_map.main[each.key].name
  docker_password       = azurerm_container_registry_token_password.main[each.key].password1.0.value
  registry_type         = "Others"
}
