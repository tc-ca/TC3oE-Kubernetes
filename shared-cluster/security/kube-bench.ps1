#!/usr/bin/env pwsh

Write-Host "Creating job" -ForegroundColor "Cyan"
kubectl apply -f "https://github.com/aquasecurity/kube-bench/raw/main/job.yaml"
Write-Host "Waiting for job to complete" -ForegroundColor "Cyan"
kubectl wait --for=condition=complete --timeout=32s -f "https://github.com/aquasecurity/kube-bench/raw/main/job.yaml"
Write-Host "Writing job results to kube-bench.txt" -ForegroundColor "Cyan"
$podName = kubectl get pods -l app=kube-bench -o name
kubectl logs $podName > kube-bench.txt
# Write-Host "Cleaning up" -ForegroundColor "Cyan"
# kubectl delete -f "https://github.com/aquasecurity/kube-bench/raw/main/job.yaml"