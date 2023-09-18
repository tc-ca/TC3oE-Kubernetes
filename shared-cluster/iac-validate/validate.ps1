#!/usr/bin/env pwsh

Push-Location ../iac-terraform
Write-Host "Fetching terraform output"
$tf_output = terraform output -json | ConvertFrom-Json -AsHashtable
Pop-Location

function Check-KeyVault($output) {
    $uri = $output.Values.key_vault_uri
    $result = [regex]::Matches($uri, "://(.*?)\.vault.azure.net/")
    $kv = $result[0].Groups[1]
    Write-Host "Discovered vault $kv"
    Write-Host "Checking for argocd PAT in $kv"
    az keyvault secret show `
        --name "argocd-personal-access-token" `
        --vault-name "$kv" `
        --output "none"
    if ($? -eq $True)
    {
        Write-Host "Found argocd PAT in $kv 😎" -ForegroundColor Green
    }
    else
    {
        # write in yellow since the `az keyvault` command error is in red and hard to separate from our custom message
        Write-Host "Couldn't find argocd-personal-access-token in $kv 💀 This secret should be manually set since we can't store the PAT in code." -ForegroundColor Yellow
    }
}

foreach ($env in $tf_output.Keys)
{
    Write-Host "Discovered env $env" -ForegroundColor Cyan
    Check-KeyVault $tf_output.$env
}