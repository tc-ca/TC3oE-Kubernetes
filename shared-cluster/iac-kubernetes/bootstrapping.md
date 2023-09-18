# Bootstrapping

## First Workloads

Once the cluster is created, the next step is getting ArgoCD running.  
The workloads needed for ArgoCD are:

1. [`workloads/workload-identity-webook`](./workloads/workload-identity-webook)
1. [`workloads/external-secrets-operator`](./workloads/external-secrets-operator)
1. [`workloads/ingress`](./workloads/ingress)
1. [`workloads/argocd`](./workloads/argocd)
1. [`workloads/app-of-apps`](./workloads/app-of-apps)

Use the [`./Control.ps1`](./Control.ps1) script to apply the workloads.  
You should use the env-specific kustomizations, not the base, when possible.

Next, run [`iac-kubernetes/tls/update-all-envs.ps1`](./tls/update-all-envs.ps1) to pull the certs into the key vault so they can be used in the cluster.

## Repo credentials

ArgoCD uses a personal access token to get READ access on the git repos. This is provided by manually setting the `argocd-personal-access-token` secret in the key vault for the environment.

## TLS and the Gateway

By default, the ingress will create its own self-signed certificate, but the gateway won't trust it.

Instead, we use external secrets operator to pull a cert from a keyvault into the Kubernetes secret used by the ingress.

The ingress is configured use the pulled certificate as a default so that client workloads don't need to bother with certs as it should "just work".

_Note: the certificate is stored in the key vault as a secret, not as a certificate. This is because of issues encountered when uploading the certificate to the key vault as a certificate._

The k8s side expects the secrets to exist in the key vault.  
**See the [iac-kubernetes/tls/update-all-envs.ps1](./tls/update-all-envs.ps1) script to pull the cert from the common vault into the cluster vault.**

## Connecting

The cluster is private, therefore `kubectl` and the control plane in the Azure Portal are only accessible from within SCED.  
The ingress controller is reverse-proxied by the application gateway; the workloads on the cluster CAN be made public facing if desired.

You need to pull the kube config using the following command:

```powershell
az aks get-credentials --resource-group myResourceGroup --name myCluster --subscription mySubscription
```

You may see the following error at some point:

> W1101 17:27:28.770162  112080 azure.go:92] WARNING: the azure auth plugin is deprecated in v1.22+, unavailable in v1.26+; use https://github.com/Azure/kubelogin instead.
> To learn more, consult https://kubernetes.io/docs/reference/access-authn-authz/authentication/#client-go-credential-plugins

Run `kubelogin convert-kubeconfig` to update the config to use the newer auth provider.  
If that doesn't work, check the links for more details.

## Switching Contexts

When dealing with multiple clusters, switching between them is a frequent action.

The following is a helpful function that you can add to your PowerShell profile script.

```pwsh
function ksc()
{
    $current = kubectl config current-context;
    Write-Host "Current context: " -NoNewline
    Write-Host -ForegroundColor "Cyan" $current
    $contexts = kubectl config get-contexts -o name | Sort-Object
    for($i=0; $i -lt $contexts.Count; $i++)
    {
        Write-Host "$($i + 1). $($contexts[$i])"
    }
    $choice = [int](Read-Host "Pick your context")
    if ($choice -eq 0)
    {
        Write-Host "Operation aborted."
    }
    else
    {
        kubectl config use-context $contexts[$choice-1]
    }
}
```

You can find the locaiton of your powershell profile by running

```pwsh
echo $profile
```

VSCode may use a different profile than the Windows Terminal application. For this reason, I usually create a `common.ps1` file and have the other profiles source it.
