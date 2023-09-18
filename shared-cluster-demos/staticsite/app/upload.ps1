#!/usr/bin/pwsh
# THIS FILE IS MANAGED BY TERRAFORM!
# IF YOU WANT TO MAKE CHANGES, EDIT `azure/app_templates` INSTEAD OF THIS FILE !!!


Write-Host "Clearing old site content" -ForegroundColor "Cyan"
az storage blob delete-batch --account-name "mydemostorageaccount" --source "webcontent" --pattern "*" --subscription "mysubscription"
Write-Host "Uploading new content" -ForegroundColor "Cyan"
az storage blob upload-batch --account-name "mydemostorageaccount" --destination "webcontent" --source "wwwroot" --subscription "mysubscription"