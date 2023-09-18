#####
## CREATE VNET
#####

data "azurerm_resource_group" "scednprdnet" {
  name = "my-nprd-vnet-rgp"
}

resource "azurerm_virtual_network" "k8s-nprd" {
  resource_group_name = data.azurerm_resource_group.scednprdnet.name
  tags                = data.azurerm_resource_group.scednprdnet.tags
  name                = "my-nprd-k8s-vnet"
  location            = "canadacentral"
  address_space = [
    "555.555.555.555/23"
  ]
}

#####
## POLICY EXEMPTION TO ENABLE SUBNET CREATION
#####

resource "time_rotating" "exemption_expiry" {
  rotation_hours = 1
}

resource "azurerm_resource_group_policy_exemption" "exemption-1" {
  exemption_category   = "Waiver"
  name                 = "allow-terraform-subnet-creation"
  description          = "terraform creates NSG associations to subnets in a separate step"
  policy_assignment_id = "/providers/Microsoft.Management/managementGroups/my-mgmt-group/providers/Microsoft.Authorization/policyAssignments/Prevent-Subnet-Without-Nsg"
  resource_group_id    = data.azurerm_resource_group.scednprdnet.id
  expires_on           = timeadd(time_rotating.exemption_expiry.rfc3339, "1h")
}

#####
## SUBNET - DEV-1
#####

resource "azurerm_subnet" "dev-1" {
  resource_group_name  = data.azurerm_resource_group.scednprdnet.name
  virtual_network_name = azurerm_virtual_network.k8s-nprd.name
  name                 = "my-aks-dev-1-subnet"
  address_prefixes     = ["555.555.555.555/26"]
  # private_endpoint_network_policies_enabled = true
  depends_on = [
    azurerm_resource_group_policy_exemption.exemption-1
  ]
}

data "azurerm_resource_group" "netsec" {
  name = "my-networking-rg"
}
data "azurerm_network_security_group" "my-nsg" {
  resource_group_name = data.azurerm_resource_group.netsec.name
  name                = "my-nprd-nsg"
}

resource "azurerm_subnet_network_security_group_association" "dev-1" {
  subnet_id                 = azurerm_subnet.dev-1.id
  network_security_group_id = data.azurerm_network_security_group.my-nsg.id
}
