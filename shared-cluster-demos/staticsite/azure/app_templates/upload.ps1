#!/usr/bin/pwsh
${warning}

Write-Host "Clearing old site content" -ForegroundColor "Cyan"
az storage blob delete-batch --account-name "${storage_account_name}" --source "${blob_container_name}" --pattern "*" --subscription "mysubscription"
Write-Host "Uploading new content" -ForegroundColor "Cyan"
az storage blob upload-batch --account-name "${storage_account_name}" --destination "${blob_container_name}" --source "wwwroot" --subscription "mysubscription"