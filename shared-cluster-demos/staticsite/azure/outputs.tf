locals {
  k8s_warning_header = <<EOT
# THIS FILE IS MANAGED BY TERRAFORM!
# IF YOU WANT TO MAKE CHANGES, EDIT `azure/kubernetes_templates` INSTEAD OF `kubernetes/templates` !!!
EOT
  app_warning_header = <<EOT
# THIS FILE IS MANAGED BY TERRAFORM!
# IF YOU WANT TO MAKE CHANGES, EDIT `azure/app_templates` INSTEAD OF THIS FILE !!!
EOT

  k8s_service_account_name = "workload-identity-demo-staticsite"
  k8s_secret_store_name = "demo-kv"
  k8s_storage_key_secret_name = "storagekey"
}

resource "local_file" "service-account" {
    filename = "../kubernetes/base/service-account.yaml"
    content = format("%s\n%s", local.k8s_warning_header, templatefile("kubernetes_templates/service-account.yaml", {
      client_id = azurerm_user_assigned_identity.dev.client_id
      tenant_id = azurerm_user_assigned_identity.dev.tenant_id
      k8s_service_account_name = local.k8s_service_account_name
    }))
}

resource "local_file" "secret-store" {
    filename = "../kubernetes/base/secret-store.yaml"
    content = format("%s\n%s", local.k8s_warning_header, templatefile("kubernetes_templates/secret-store.yaml", {
      vault_url = azurerm_key_vault.dev.vault_uri
      k8s_service_account_name = local.k8s_service_account_name
      k8s_secret_store_name = local.k8s_secret_store_name
    }))
}

resource "local_file" "secret-storagekey" {
    filename = "../kubernetes/base/secret-storagekey.yaml"
    content = format("%s\n%s", local.k8s_warning_header, templatefile("kubernetes_templates/secret-storagekey.yaml", {
      k8s_secret_store_name = local.k8s_secret_store_name
      storage_key_secret_name = azurerm_key_vault_secret.demo_staticsite_storagekey.name
      k8s_storage_key_secret_name = "storagekey"
      storage_account_name = azurerm_storage_account.dev.name
    }))
}

resource "local_file" "deployment" {
    filename = "../kubernetes/base/deployment.yaml"
    content = format("%s\n%s", local.k8s_warning_header, templatefile("kubernetes_templates/deployment.yaml", {
      k8s_storage_key_secret_name = "storagekey"
    }))
}


resource "local_file" "upload" {
    filename = "../app/upload.ps1"
    content = templatefile("app_templates/upload.ps1", {
      warning = local.app_warning_header
      storage_account_name = azurerm_storage_account.dev.name
      blob_container_name = azurerm_storage_container.dev.name
    })
}

