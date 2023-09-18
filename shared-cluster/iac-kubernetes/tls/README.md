# IaC-TLS

Our cluster config needs the TLS cert to be stored as secrets (NOT as a certificate) inside an azure key vault.

The [update-all-envs.ps1](./update-all-envs.ps1) script takes care of copying the cert information to where k8s expects it to be.

## Troubleshooting

The gateway backend probe may complain about CN not being trusted.

Here's some tricks to help diagnose what is going on:

- Identify what cert is being used
    1. Modify hosts file to point the domain directly to the cluster IP instead of the gateway IP
    2. Wipe browser name resolution cache
        1. [edge://net-internals/#sockets](edge://net-internals/#sockets) => Flush socket pools
        2. [edge://net-internals/#dns](edge://net-internals/#dns) => Clear host cache
    3. Visit failing host in browser
    4. Receive "Your connection isn't private" warning
    5. Inspect cert using browser to see what is being served
- Look at the tls secret
    1. `kubectl get secret -n ingress-nginx my-ssl-secret -o yaml`
    2. If problems, double check the secretstore and the externalsecret resources in the `ingress-nginx` namespace to ensure no issues in the event logs

