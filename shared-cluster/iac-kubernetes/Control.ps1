#!/usr/bin/env pwsh

# $clusters = kubectl config get-clusters | Select-Object -Skip 1 | Sort-Object
$clusters = kubectl config get-clusters | Sort-Object
Write-Host "Clusters:" -ForegroundColor Cyan
for($i=1; $i -le $clusters.Count; $i++)
{
    Write-Host "$i. $($clusters[$i-1])"
}
$cluster = Read-Host "Choose your cluster"
if ($cluster -notin 1..$clusters.Count)
{
    Write-Error "bad choice: $cluster"
    exit 1
}
$cluster = $clusters[$cluster-1] # convert from index to value

$workloads = Get-ChildItem -Recurse | Where-Object { ($_.Name -eq "kustomization.yaml") -and (-not ($_.Name -contains "templates")) }
Write-Host "Workloads:" -ForegroundColor Cyan
$cwd = (Get-Location).Path
for($i=1; $i -le $workloads.Count; $i++)
{
    $relativePath = $workloads[$i-1].FullName.Replace($cwd + '\', '')
    $color = ($i % 2 -eq 0) ? 'DarkMagenta' : 'DarkCyan'
    Write-Host "$i. $relativePath" -ForegroundColor $color
}
$workload = Read-Host "Choose your workload"
if ($workload -notin 1..$workloads.Count)
{
    Write-Error "bad choice: $workload"
    exit 1
}
$workload = $workloads[$workload-1] # convert from index to value

Write-Host "Operations:" -ForegroundColor Cyan
Write-Host "1. Apply"
Write-Host "2. Delete"
$operation = Read-Host "Choose your operation"
if ($operation -notin 1..2)
{
    Write-Error "bad choice: $operation"
    exit 1
}
$operation = @("apply","delete")[$operation-1]

Write-Host -ForegroundColor Yellow -NoNewLine "About to "
Write-Host -ForegroundColor Cyan -NoNewLine $operation 
Write-Host -ForegroundColor Yellow " with the following:"
Write-Host -NoNewline "Cluster: "
Write-Host -ForegroundColor Cyan "$cluster"
Write-Host -NoNewline "Workload: "
Write-Host -ForegroundColor Cyan "$workload"
$confirmation = Read-Host "Are you sure you want to proceed? (y/N)"
if ($confirmation -ne 'y') {
    Write-Host "Operation cancelled"
    exit
}

Push-Location $workload.Directory
if ($operation -eq "apply")
{
    kubectl kustomize --enable-helm | kubectl apply --cluster $cluster -f -
}
elseif ($operation -eq "delete")
{
    kubectl kustomize --enable-helm | kubectl delete --cluster $cluster -f -
}
Pop-Location
