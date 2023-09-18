You can destory a cluster resources using:
```pwsh
terraform state list | Select-String kubernetes
# pick the cluster to destroy
terraform destroy --target module.acc.azurerm_kubernetes_cluster.main
```
You can destroy an environment using
```pwsh
terraform destroy --target module.acc
```
Simply removing the module implementation may cause terraform to complain, so do a targeted destroy before removing the code.