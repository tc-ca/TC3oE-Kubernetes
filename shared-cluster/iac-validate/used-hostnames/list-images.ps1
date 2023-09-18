#!/usr/bin/env pwsh

$pods = kubectl get pods --all-namespaces -o json | ConvertFrom-Json -AsHashtable
$images = $pods.items.spec.containers.image | Sort-Object -Unique | ForEach-Object {
    $slashes = ($_ -split '/' ).Count - 1

    # If the image name contains more than one slash, it has a registry domain
    if ($slashes -gt 1) {
        $_
    }
    # If the image name doesn't contain a slash, it's an official Docker image
    # We prepend 'docker.io/library/'
    elseif ($slashes -eq 0) {
        "docker.io/library/$_"
    }
    # If the image name contains one slash, it includes a user or organization name
    else {
        "docker.io/$_"
    }
}
Write-Host "Used images:"
$images | Format-Table

Write-Host "`n`nContainer registries:"
$images | ForEach-Object { $($_ -split "/")[0]} | Sort-Object -Unique