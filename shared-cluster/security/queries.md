# Queries

The Logs blade in the AKS resource seems to give more information than going to the LAW itself, which is concerning but I don't have time to enter the rabbit hole to find an explanation.

Here's a query for finding Kubernetes API server activity by a specific person:

```kusto
AzureDiagnostics
| where TimeGenerated > ago(30d)
| where Category=="kube-audit"
| extend data=parse_json(log_s)
| extend usa=tostring(data.user.username)
| extend req=data.requestURI
| extend ips=data.sourceIPs
| where usa=="first.last@org.gc.ca"
| limit 5000
```

