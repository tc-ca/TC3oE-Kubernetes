variable "projects" {
  type = map(object({ # key is name
    description         = string
    security_group_id   = string,
    devops_project_name = string,
    acr_image_names     = set(string)
    apps = map(object({ # key is name
      k8s_namespace = string
      envs = object({
        dev_1 = object({
          source_repo_url        = string
          source_target_revision = string
          source_path            = string
        })
        acc_1 = object({
          source_repo_url        = string
          source_target_revision = string
          source_path            = string
        })
      })
    }))
  }))
  default = {
    cluster-stuff = {
      description = "Core cluster workloads"
      security_group_id   = "555-555-555-555" # cloud admins
      acr_image_names     = []
      devops_project_name = "my-devops-proj"
      apps = {
        app-of-apps = {
          k8s_namespace = "argocd"
          envs = {
            dev_1 = {
              source_repo_url        = "https://git.org.gc.ca/cluster-stuff"
              source_target_revision = "main"
              source_path            = "iac-kubernetes/workloads/app-of-apps/overlays/dev/"
            }
          }
        }
        argocd = {
          k8s_namespace = "argocd"
          envs = {
            dev_1 = {
              source_repo_url        = "https://git.org.gc.ca/cluster-stuff"
              source_target_revision = "main"
              source_path            = "iac-kubernetes/workloads/argocd/overlays/dev/"
            }
          }
        }
        azure-monitor-agent = {
          k8s_namespace = "kube-system"
          envs = {
            dev_1 = {
              source_repo_url        = "https://git.org.gc.ca/cluster-stuff"
              source_target_revision = "main"
              source_path            = "iac-kubernetes/workloads/azure-monitor-agent"
            }
          }
        }
        blob-csi-driver = {
          k8s_namespace = "kube-system"
          envs = {
            dev_1 = {
              source_repo_url        = "https://git.org.gc.ca/cluster-stuff"
              source_target_revision = "main"
              source_path            = "iac-kubernetes/workloads/blob-csi-driver"
            }
          }
        }
        external-secrets-operator = {
          k8s_namespace = "external-secrets"
          envs = {
            dev_1 = {
              source_repo_url        = "https://git.org.gc.ca/cluster-stuff"
              source_target_revision = "main"
              source_path            = "iac-kubernetes/workloads/external-secrets-operator"
            }
          }
        }
        ingress-nginx = {
          k8s_namespace = "ingress-nginx"
          envs = {
            dev_1 = {
              source_repo_url        = "https://git.org.gc.ca/cluster-stuff"
              source_target_revision = "main"
              source_path            = "iac-kubernetes/workloads/ingress-nginx/overlays/dev/"
            }
          }
        }
        workload-identity-webhook = {
          k8s_namespace = "azure-workload-identity-system"
          envs = {
            dev_1 = {
              source_repo_url        = "https://git.org.gc.ca/cluster-stuff"
              source_target_revision = "main"
              source_path            = "iac-kubernetes/workloads/workload-identity-webhook"
            }
          }
        }
      }
    }
    demos = {
      description         = "Kubernetes Demos"
      security_group_id   = "555-555-555-555" # cloud admins
      acr_image_names     = ["counter-demo"]
      devops_project_name = "my-devops-proj"
      apps = {
        demo-counter = {
          k8s_namespace = "demo-counter"
          envs = {
            dev_1 = {
              source_repo_url        = "https://git.org.gc.ca/cluster-stuff-demos"
              source_target_revision = "main"
              source_path            = "counter/kubernetes/overlays/dev"
            }
          }
        }
        demo-hello = {
          k8s_namespace = "demo-hello"
          envs = {
            dev_1 = {
              source_repo_url        = "https://git.org.gc.ca/cluster-stuff-demos"
              source_target_revision = "main"
              source_path            = "hello/kubernetes/overlays/dev"
            }
          }
        }
        "demo-staticsite" = {
          k8s_namespace = "demo-staticsite"
          envs = {
            dev_1 = {
              source_repo_url        = "https://git.org.gc.ca/cluster-stuff-demos"
              source_target_revision = "main"
              source_path            = "staticsite/kubernetes/overlays/dev"
            }
          }
        }
      }
    }
    self-service-portal = {
      acr_image_names     = ["selfserviceportal"]
      security_group_id   = "555-555-555-555" # self-service-portal-ops
      description         = "self service portal application"
      devops_project_name = "my-devops-proj"
      apps = {
        self-service-portal = {
          k8s_namespace = "self-service-portal"
          envs = {
            dev_1 = {
              source_repo_url        = "https://git.org.gc.ca/SelfServicePortal-Infrastructure-as-Code"
              source_target_revision = "master"
              source_path            = "kubernetes/overlays/dev"
            }
            acc_1 = {
              source_repo_url        = "https://git.org.gc.ca/SelfServicePortal-Infrastructure-as-Code"
              source_target_revision = "master"
              source_path            = "kubernetes/overlays/acc"
            }
          }
        }
      }
    }
  }
}