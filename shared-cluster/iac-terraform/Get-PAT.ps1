#!/usr/bin/env pwsh
# note: running this from bash does nothing. launch from pwsh
$Env:AZDO_PERSONAL_ACCESS_TOKEN=az keyvault secret show --name MyPersonalAccessToken --vault-name my-terraform-key-vault --query value -o tsv