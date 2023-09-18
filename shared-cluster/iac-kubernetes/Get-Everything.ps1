#!/usr/bin/env pwsh

param(
    [string]
    $namespace
)
# Kubernetes sucks and sometimes prevents namespaces from fully terminating.
# We need to list all the CRDs, then query each one to find what the heck is stopping us.
kubectl api-resources --verbs=list --namespaced -o name | % { kubectl get --show-kind --ignore-not-found -n $namespace $_ }