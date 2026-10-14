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
3. `az acr create --name <acr-name> --resource-group <rg-name> --sku Basic`
4. `az containerapp env create --name <env-name> --resource-group <rg-name> --location <region>`
5. Set these repository secrets:
   - `AZURE_CLIENT_ID`
   - `AZURE_TENANT_ID`
   - `AZURE_SUBSCRIPTION_ID`
   - `AZURE_CLIENT_SECRET`
   - `ACR_LOGIN_SERVER` from `az acr show --name <acr-name> --resource-group <rg-name> --query loginServer -o tsv`
   - `ACR_USERNAME` from `az acr credential show --name <acr-name> --resource-group <rg-name> --query username -o tsv`
   - `ACR_PASSWORD` from `az acr credential show --name <acr-name> --resource-group <rg-name> --query passwords[0].value -o tsv`
   - `AZURE_RESOURCE_GROUP` set to `<rg-name>`
   - `AZURE_CONTAINERAPP_NAME` set to `<app-name>`
   - `AZURE_CONTAINERAPPS_ENVIRONMENT` set to `<env-name>`
6. `gh workflow run "Azure Container Apps CI/CD"`
7. Verify the live URL: `az containerapp show --name <app-name> --resource-group <rg-name> --query "properties.configuration.ingress.fqdn" -o tsv`
8. Update `azure_resource.md` with the actual resource details, commit and push.
