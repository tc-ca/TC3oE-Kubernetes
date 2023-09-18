#!/usr/bin/env pwsh

Write-Host -ForegroundColor "DarkMagenta" "Investigating $(kubectl config current-context)"
Write-Host -ForegroundColor "Cyan" "Creating pod"
kubectl apply -f ./pod.yaml

Write-Host -ForegroundColor "Cyan" "Waiting for pod to leave the ContainerCreating state"
do {
    $podJson = kubectl get pod investigation -o json | ConvertFrom-Json
    $status = $podJson.status.phase
    $waitingReason = $podJson.status.containerStatuses[0].state.waiting.reason

    if ($status -eq "Pending" -and $waitingReason -eq "ContainerCreating") {
        Start-Sleep -s 10
    } elseif ($status -eq "Running") {
        break
    } elseif ($waitingReason -eq "ErrImagePull") {
        Write-Error "Failed to pull image"
        exit 1
    } else {
        Write-Error "Pod failed to start. Status: $status, Waiting Reason: $waitingReason"
        exit 1
    }
} while ($true)

Write-Host -ForegroundColor "Cyan" "Testing network connection"

$checks=$(
    "cat /etc/resolv.conf",
    "wget https://docker.io -O /dev/null",
    "wget https://quay.io -O /dev/null",
    "wget --header='Host: example.com' --no-check-certificate https://93.184.216.34 -O /dev/null",
    "nslookup kubernetes.default.svc.cluster.local", #https://techcommunity.microsoft.com/t5/core-infrastructure-and-security/mastering-aks-troubleshooting-1-resolving-connectivity-and-dns/ba-p/3814187
    "dig +add +trace example.com"
)
foreach ($check in $checks)
{
    Write-Host -ForegroundColor "Yellow" "$check"
    kubectl exec -it investigation -- /bin/sh -c "$check"
}

Write-Host -ForegroundColor "Cyan" "Shelling into pod"
kubectl exec -it investigation -- /bin/sh
# kubectl exec -it investigation -- bash

Write-Host -ForegroundColor "Cyan" "Cleaning up pod"
kubectl delete pod investigation --force --grace-period=0
