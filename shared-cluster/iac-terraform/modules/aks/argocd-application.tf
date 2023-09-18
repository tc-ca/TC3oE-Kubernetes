variable "argo_aad_app_name" {
  type = string
}
variable "argo_aad_app_owners" {
  type = set(string)
}
variable "argocd_hostname" {
  type = string
}

resource "azuread_application" "argocd" {
  display_name = var.argo_aad_app_name
  web {
    redirect_uris = ["https://${var.argocd_hostname}/auth/callback"]
    implicit_grant {
      id_token_issuance_enabled = true
    }
  }
  optional_claims {
    access_token {
      additional_properties = []
      essential             = false
      name                  = "groups"
    }
    id_token {
      additional_properties = []
      essential             = false
      name                  = "groups"
    }
    saml2_token {
      additional_properties = []
      essential             = false
      name                  = "groups"

    }
  }

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000"
    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d" # user.read
      type = "Scope"
    }
  }
  owners = var.argo_aad_app_owners


  group_membership_claims = [
    "All"
  ]
}

resource "azuread_application_password" "argocd" {
  application_object_id = azuread_application.argocd.object_id
}
