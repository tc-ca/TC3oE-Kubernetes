# Network Connectivity

At some point we had clusters described with Terraform, but not the corresponding route tables.
We added new route tables to Terraform, but the clusters didn't appreciate the switch.

[See here for more info about AKS and route tables](https://learn.microsoft.com/en-us/azure/aks/configure-kubenet#bring-your-own-subnet-and-route-table-with-kubenet)

I believe switching route tables to be the cause of some weird networking problems within the cluster, since AKS doesn't expect the table to change.
In the end, the solution was to destroy and recreate the cluster, which was pretty easy since it's all managed by Terraform.

You can destory a cluster using:

```pwsh
terraform state list | Select-String kubernetes
# pick the cluster to destroy
terraform destroy --target module.acc.azurerm_kubernetes_cluster.main
```

then simply run `terraform apply` for it to recreate the missing pieces.
