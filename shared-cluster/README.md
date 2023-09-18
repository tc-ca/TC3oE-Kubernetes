# Cloud Shared AKS

The goal of the shared cluster initiative is to provide a consistent, developer-focused, compliant environment for deploying applications.

The hope is that using the cluster is a more convenient experience for app teams, while also saving costs by sharing resources between teams.

## Usage
### 00 - Prerequisites - Software

Install the following:

- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Terraform](https://developer.hashicorp.com/terraform/tutorials/azure-get-started/install-cli)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/) (this can be installed via `az aks install-cli`)
- [Helm](https://helm.sh/docs/intro/install/)
- [Kustomize](https://github.com/kubernetes-sigs/kustomize)

I also recommend:

- [K9s](https://github.com/derailed/k9s)

### 01 - Azure Resource Provisioning

We use Terraform to manage the non-Kubernetes resources.

If you're deploying a new environment/cluster, you will need to edit `azure/modules.tf` to reflect the desired state.

Make sure you have the `Application Developer` AAD role activated in Azure PIM, sicne you need to be able to create new AAD applications.

Next, we need to pull the access token used by the Azure DevOps Terraform provider, then run `terraform apply`.

```powershell
cd azure
. ./Get-PAT.PS1
terraform apply
```

## Best? Practices

### Kustomize vs Helm

I recommend prioritizing Kustomize over Helm. Helm complains if it believes that resources aren't managed by Helm, and there is not any flag to override this behaviour. Kustomize can include Helm charts, and it cares less about where stuff came from, and it is happy to override resources as one expects and needs.

Use Kustomize.

### Pod Security

By default, we should try for `restricted` pod security by default.

This will prevent pods from being created if they don't meet certain criteria, like `allowPrivilegeEscalation: false`.

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: argocd
  labels:
    pod-security.kubernetes.io/enforce: restricted
```

Some apps aren't quite there yet, and it might be necessary to lower our expectations.

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: ingress-nginx
  labels:
    pod-security.kubernetes.io/enforce: baseline
```


## Useful links

- https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/containers/aks/secure-baseline-aks
- https://docs.microsoft.com/en-us/azure/aks/configure-kubenet
- https://docs.microsoft.com/en-us/azure/aks/internal-lb
- https://docs.microsoft.com/en-us/azure/aks/ingress-basic?tabs=azure-cli

- Security: https://www.youtube.com/watch?v=AgFwbOyneEI


## Networking (with Gateways)

Right now, the cluster sits behind an Azure Application Gateway.

Sometimes, the gateway healthprobe fails and that causes the gateway to give a 504 instead of allowing traffic to flow to the cluster.

To help with diagnosing issues, it's possible to edit your system `/etc/hosts` file to skip the gateway and have your traffic go directly to the cluster.

PowerToys has a [nice hosts editor](https://learn.microsoft.com/en-us/windows/powertoys/hosts-file-editor) for convenience.

After editing hosts, it may be necessary to manually flush the browser DNS and sockets
- [edge://net-internals/#dns](edge://net-internals/#dns)
- [edge://net-internals/#sockets](edge://net-internals/#sockets)

It may also be necessary to run `ipconfig /flushdns` in cmd.

Check the external IP on the ingress-nginx-controller service to find what you should have the hosts file point to.


## A note about Docker and containerized development patterns

Docker desktop recently (2022) changed their licensing agreements, meaning that enterprise and government usage would no longer be allowed under the free tier of Docker Desktop. Note that Docker Desktop is different from the Docker engine, the latter still being free to use. Without Docker Desktop however, Windows development becomes more complicated.

There are a few ways to continue to develop containerized applications for free:

1. Use Docker on a linux VM in the cloud
2. Use Docker engine via WSL2
3. Use Podman Desktop (requires WSL2) to replace Docker Desktop
4. **Use Podman engine via WSL2**

Personally, I have had the most success using method 4., which only requires WSL2 and does not involve installing Podman or Docker on the Windows side of the machine. I tried using the previous methods but reached various road blocks leading to method 4 being the best for me.

It is important to note that the Cisco AnyConnect VPN [doesn't play well with WSL](https://github.com/microsoft/WSL/issues/4277), meaning network connectivity in WSL will be unavailable while the VPN is active. Turns out, it's possible to get WSL to work under the VPN, [here's the guide I used](https://gist.github.com/pyther/b7c03579a5ea55fe431561b502ec1ba8)

Podman also had issues pulling, editing resolv.conf seems to have fixed? [ref](https://github.com/containers/podman/discussions/16693#discussioncomment-5337355)

## Tools that might be interesting but we aren't using yet

- https://cuelang.org/
- https://kpt.dev/
- https://backstage.io/

## Troubleshooting and FAQ

> AKS can't pull from ACR

https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/cannot-pull-image-from-acr-to-aks-cluster

Make sure you're using the agent pool identity (`kubelet_identity` property on the AKS object in Terraform) instead of the AKS identity.

---

> How do I set up sticky sessions

https://kubernetes.github.io/ingress-nginx/examples/affinity/cookie/

```diff
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: counter-ing
  namespace: counter
  annotations:
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
+    nginx.ingress.kubernetes.io/affinity: cookie
```

---

> What namespaces are Azure built-in vs other stuff that I may have installed?

The namespaces that come with a fresh AKS instance are:

- kube-node-lease
- kube-public
- kube-system
- default
- gatekeeper-system
