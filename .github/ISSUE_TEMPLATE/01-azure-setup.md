---
name: "Issue 1 — Azure Container Apps Setup"
about: "Deploy blank pages to one Azure Container App"
title: "Azure Container Apps Setup"
labels: "init-demo"
---

## Task
Deploy this repo as one container running on Azure Container Apps.

### Steps
1. `az login`
2. `az group create --name <rg-name> --location <region>`
3. `az acr create --name <acr-name> --resource-group <rg-name> --sku Basic --admin-enabled false`
4. `az containerapp env create --name <env-name> --resource-group <rg-name> --location <region>`
5. Bootstrap the Container App with a public image and a system-assigned identity, grant it `AcrPull` on ACR, and configure ACR registry authentication to use that identity.
6. Create a federated credential for `repo:<owner>/<repo>:ref:refs/heads/<branch>` with issuer `https://token.actions.githubusercontent.com` and audience `api://AzureADTokenExchange`. Grant the GitHub deployment principal `Container Apps Contributor` on the resource group and `AcrPush` on the registry.
7. Set these repository secrets:
   - `AZURE_CLIENT_ID`
   - `AZURE_TENANT_ID`
   - `AZURE_SUBSCRIPTION_ID`
8. Set these repository variables: `ACR_LOGIN_SERVER`, `AZURE_RESOURCE_GROUP`, and `AZURE_CONTAINERAPP_NAME`.
9. Trigger `gh workflow run "Azure Container Apps CI/CD" --ref <branch>` from the federated branch.
10. Verify the live URL responds successfully and update `azure_resource.md` with actual resource details.

Use GitHub OIDC and managed identities; do not configure `AZURE_CLIENT_SECRET`, `ACR_USERNAME`, or `ACR_PASSWORD`.
