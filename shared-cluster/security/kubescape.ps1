#!/usr/bin/env pwsh

$Env:AZURE_SUBSCRIPTION_ID="555-555-5555-555"
$Env:AZURE_RESOURCE_GROUP="our-resource-group"
$Env:KS_CLOUD_PROVIDER="aks"
kubescape scan --enable-host-scan --verbose *>&1 > kubescape.txt