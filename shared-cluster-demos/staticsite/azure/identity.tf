resource "azurerm_user_assigned_identity" "dev" {
  resource_group_name = data.azurerm_resource_group.main.name
  tags                = data.azurerm_resource_group.main.tags
  name                = "mydemoidentity"
  location            = "canadacentral"
}

resource "azurerm_federated_identity_credential" "dev" {
  resource_group_name = data.azurerm_resource_group.main.name
  parent_id           = azurerm_user_assigned_identity.dev.id
  name                = "fedcred-dev"
  # todo: find way to distribute this to clients
  # maybe a key vault secret?
  issuer              = "https://canadacentral.oic.prod-aks.azure.com/555-555-555-5555/555-555-555-5555"
  subject             = "system:serviceaccount:demo-staticsite:workload-identity-demo-staticsite"
  audience            = ["api://AzureADTokenExchange"]
}


resource "azurerm_federated_identity_credential" "acc" {
  resource_group_name = data.azurerm_resource_group.main.name
  parent_id           = azurerm_user_assigned_identity.dev.id
  name                = "fedcred-acc"
  issuer              = "https://canadacentral.oic.prod-aks.azure.com/666-666-666-6666/666-666-666-6666"
  subject             = "system:serviceaccount:demo-staticsite:workload-identity-demo-staticsite"
  audience            = ["api://AzureADTokenExchange"]
}
