#!/usr/bin/env pwsh

Write-Host "Pulling cert from key vault" -ForegroundColor Cyan
az keyvault secret download `
    --name "our-backend-cert" `
    --vault-name "ourkeyvault" `
    --subscription "oursub" `
    --file "data.p12.b64"

Write-Host "Converting from base64" -ForegroundColor Cyan
$content = Get-Content -Path "data.p12.b64"
$bytes = [System.Convert]::FromBase64String($content)
Set-Content -Path "data.p12" -Value $bytes -AsByteStream

Write-Host "Discovering openssl" -ForegroundColor Cyan
if (-not(Get-Command openssl))
{
    $opensslpath = "C:\Program Files\Git\usr\bin\openssl.exe"
    if (Test-Path -Path $opensslpath -PathType Leaf) {
        Set-Alias "openssl" $opensslpath
    } else {
        Write-Host "Couldn't find openssl!" -ForegroundColor Red
        exit 1;
    }
}


# https://stackoverflow.com/a/27497899/11141271
# -clerts   => only client certs, not CA ones
# -nodes    => no DES, do not encrypt the private key
# -nocerts  => only private key in output
# -nokeys    => only certs in output
Write-Host "Converting cert" -ForegroundColor Cyan
openssl pkcs12 -in data.p12 -clcerts -nokeys -nodes -out  data.crt -password pass:
openssl pkcs12 -in data.p12 -clcerts -nocerts -nodes -out  data.key -password pass:

Write-Host "Getting terraform output" -ForegroundColor Cyan
Push-Location ../../iac-terraform
$outputs = terraform output -json | ConvertFrom-Json -AsHashtable
Pop-Location

Write-Host "Discovering vaults" -ForegroundColor Cyan
$vaults = @()
foreach ($env in $outputs.envs.value.Keys)
{
    $uri = $outputs.envs.value.$env.key_vault_uri
    $result = [regex]::Matches($uri, "://(.*?)\.vault.azure.net/")
    $kv = $result[0].Groups[1]
    Write-Host "Discovered vault $kv"
    $vaults += @($kv)
}

Write-Host "Uploading to vaults" -ForegroundColor Cyan
foreach ($vault in $vaults)
{
    Write-Host "Uploading to $vault"
    # output to $null so that we don't leak secrets in the notebook output
    az keyvault secret set --name "cluster-ssl-cert" --vault-name "$vault" --file "data.crt" > $null
    az keyvault secret set --name "cluster-ssl-key" --vault-name "$vault" --file "data.key" > $null
}