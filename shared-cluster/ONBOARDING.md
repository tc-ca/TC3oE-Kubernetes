# Onboarding

1. Modify [projects.tf](iac-terraform/projects.tf) to add a new project
1. Run Get-PAT.ps1 to set the environment variable with the PAT that lets Terraform create service connections
    - make sure you're in a `pwsh` shell since bash doesn't like the way it adds the environment variables
1. Run `terraform apply``
1. Run [manifest_templates.ipynb](iac-kubernetes/manifest_templates.ipynb)