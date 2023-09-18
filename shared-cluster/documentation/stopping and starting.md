# Stopping and Starting

We can turn the cluster off for cost savings, since stopping the cluster deprovisions most compute and stops Azure Monitor ingestion.

The [docs](https://learn.microsoft.com/en-us/azure/aks/start-stop-cluster?tabs=azure-cli#start-an-aks-cluster) recommend not doing this repeatedly:

> Don't repeatedly stop and start your clusters. This can result in errors. Once your cluster is stopped, you should wait at least 15-30 minutes before starting it again.

Additionally, once we have clients actually using the clusters, then we can probably stop the non-prod clusters during off-hours, but it might be best to not stop the prod one lol.