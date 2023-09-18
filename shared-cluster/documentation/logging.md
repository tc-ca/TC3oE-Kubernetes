# Logging

There's the container insights logging, which we have configured:

https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-overview

There is also Prometheus metrics, which we have NOT configured:

https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/prometheus-metrics-overview

For now, we aren't sophisticated enough to need Prometheus logging. The Azure Monitor logging should be fine for our needs. If this changes, it should be fairly trivial to enable Prometheus, but for now it's just not necessary (not to mention might increase data volume, raising costs).

## Queries

Here's some queries that might be helpful.

### Kube API server

```kql
AzureDiagnostics
| where TimeGenerated > ago(3d)
| where Category=="kube-audit"
| extend data=parse_json(log_s)
| extend usa=tostring(data.user.username)
| extend req=data.requestURI
| extend ips=data.sourceIPs
| extend verb=data.verb
| where usa=="first.last@org.gc.ca"
```

### Data volume by table over time

```kql
let mark = ago(31d);
let TotalIngestion=toscalar(
    Usage
    | where TimeGenerated > mark
    | summarize IngestionVolume=sum(Quantity));
let DataTypeContribution = Usage
    | where TimeGenerated > mark
    | where IsBillable
    | project DataType, Quantity
    | summarize DataTypeIngestion=sum(Quantity) by DataType
    | project DataType, DataTypeIngestionPercent=(DataTypeIngestion / TotalIngestion)
    | where DataTypeIngestionPercent > 0.01;
Usage
| where TimeGenerated > mark
| where IsBillable
| join kind=inner DataTypeContribution on DataType
| summarize IngestionVolume=sum(Quantity) by bin(TimeGenerated,1d), DataType
| render columnchart 
```

### Data volume over time

```kql
Usage
| where TimeGenerated > ago(31d)
| where IsBillable
| summarize sum(Quantity) by bin(TimeGenerated, 1d)
| render columnchart 
```