# template-azureapp.md

Purpose: Reusable template to accelerate resolving Issue #1 (Azure Container Apps Setup) without modifying unrelated repository files.

## Scope Guardrails

- Do not edit content pages while completing Issue #1.
- Focus only on Azure infrastructure setup, secret setup, workflow trigger, verification, and `azure_resource.md` update.

## Reusable Prompt (Copy/Paste)

Use this exact prompt when starting execution:

"address issue #1 Azure Container Apps Setup (Pre-demo) based on template-azureapp.md"

When executing, follow this template strictly and avoid unrelated changes.

## Fill-In Inputs

Replace placeholders before running commands.

- [SUBSCRIPTION_ID]: Azure subscription ID
- [RESOURCE_GROUP]: Resource group name (example: rg-ghcp-demo)
- [LOCATION]: Azure region (example: swedencentral)
- [ACR_NAME]: Azure Container Registry name (example: ghcpdemoregistry)
- [CONTAINERAPPS_ENV]: Container Apps environment name (example: ghcp-demo-env)
- [CONTAINER_APP_NAME]: Container App name (example: ghcp-demo-app)
- [GITHUB_OWNER]: GitHub org/user
- [GITHUB_REPO]: Repository name
- [WORKFLOW_NAME]: Azure Container Apps CI/CD

## Runbook (Issue #1)

1. Create or confirm the resource group.
2. Create Azure Container Registry (Basic SKU).
3. Create Azure Container Apps environment.
4. Configure repository secrets needed by the workflow.
5. Trigger workflow [WORKFLOW_NAME].
6. Wait for workflow completion and confirm success.
7. Verify the live URL responds with HTTP 200.
8. Update `azure_resource.md` with actual values.

## Command Checklist (CLI)

Run from anywhere with `az` and `gh` authenticated.

```bash
# 0) Optional: set subscription context
az account set --subscription "[SUBSCRIPTION_ID]"

# 1) Create resource group (idempotent)
az group create \
  --name "[RESOURCE_GROUP]" \
  --location "[LOCATION]"

# 2) Create ACR (idempotent with same name)
az acr create \
  --name "[ACR_NAME]" \
  --resource-group "[RESOURCE_GROUP]" \
  --sku Basic

# 3) Create Container Apps environment
az containerapp env create \
  --name "[CONTAINERAPPS_ENV]" \
  --resource-group "[RESOURCE_GROUP]" \
  --location "[LOCATION]"

# 4) Collect ACR values
ACR_LOGIN_SERVER=$(az acr show \
  --name "[ACR_NAME]" \
  --resource-group "[RESOURCE_GROUP]" \
  --query loginServer -o tsv)

ACR_USERNAME=$(az acr credential show \
  --name "[ACR_NAME]" \
  --resource-group "[RESOURCE_GROUP]" \
  --query username -o tsv)

ACR_PASSWORD=$(az acr credential show \
  --name "[ACR_NAME]" \
  --resource-group "[RESOURCE_GROUP]" \
  --query passwords[0].value -o tsv)

# 5) Set GitHub repo secrets
printf "%s" "<AZURE_CLIENT_ID>" | gh secret set AZURE_CLIENT_ID \
  --repo "[GITHUB_OWNER]/[GITHUB_REPO]"
printf "%s" "<AZURE_TENANT_ID>" | gh secret set AZURE_TENANT_ID \
  --repo "[GITHUB_OWNER]/[GITHUB_REPO]"
printf "%s" "<AZURE_SUBSCRIPTION_ID>" | gh secret set AZURE_SUBSCRIPTION_ID \
  --repo "[GITHUB_OWNER]/[GITHUB_REPO]"
printf "%s" "<AZURE_CLIENT_SECRET>" | gh secret set AZURE_CLIENT_SECRET \
  --repo "[GITHUB_OWNER]/[GITHUB_REPO]"
printf "%s" "$ACR_LOGIN_SERVER" | gh secret set ACR_LOGIN_SERVER \
  --repo "[GITHUB_OWNER]/[GITHUB_REPO]"
printf "%s" "$ACR_USERNAME" | gh secret set ACR_USERNAME \
  --repo "[GITHUB_OWNER]/[GITHUB_REPO]"
printf "%s" "$ACR_PASSWORD" | gh secret set ACR_PASSWORD \
  --repo "[GITHUB_OWNER]/[GITHUB_REPO]"
printf "%s" "[RESOURCE_GROUP]" | gh secret set AZURE_RESOURCE_GROUP \
  --repo "[GITHUB_OWNER]/[GITHUB_REPO]"
printf "%s" "[CONTAINER_APP_NAME]" | gh secret set AZURE_CONTAINERAPP_NAME \
  --repo "[GITHUB_OWNER]/[GITHUB_REPO]"
printf "%s" "[CONTAINERAPPS_ENV]" | gh secret set AZURE_CONTAINERAPPS_ENVIRONMENT \
  --repo "[GITHUB_OWNER]/[GITHUB_REPO]"

# 6) Trigger deployment workflow
gh workflow run "[WORKFLOW_NAME]" \
  --repo "[GITHUB_OWNER]/[GITHUB_REPO]"

# 7) Get latest run ID
RUN_ID=$(gh run list \
  --repo "[GITHUB_OWNER]/[GITHUB_REPO]" \
  --workflow "[WORKFLOW_NAME]" \
  --limit 1 --json databaseId --jq '.[0].databaseId')

# 8) Wait until complete
gh run watch "$RUN_ID" \
  --repo "[GITHUB_OWNER]/[GITHUB_REPO]" \
  --interval 10

# 9) Show final run status
gh run view "$RUN_ID" \
  --repo "[GITHUB_OWNER]/[GITHUB_REPO]" \
  --json conclusion,status,url,displayTitle,startedAt,updatedAt

# 10) Verify live URL is accessible
FQDN=$(az containerapp show \
  --name "[CONTAINER_APP_NAME]" \
  --resource-group "[RESOURCE_GROUP]" \
  --query "properties.configuration.ingress.fqdn" -o tsv)

curl -I -L --max-time 20 "https://$FQDN"
```

## Completion Evidence (Paste Into Issue #1 Comment)

- Container App: [CONTAINER_APP_NAME]
- Container Apps Environment: [CONTAINERAPPS_ENV]
- ACR Login Server: [ACR_LOGIN_SERVER]
- Resource Group: [RESOURCE_GROUP]
- Live URL: https://[FQDN]
- Workflow: [WORKFLOW_NAME]
- Workflow run URL: [WORKFLOW_RUN_URL]
- Verification: HTTP 200 received from https://[FQDN]

## Issue Closure Command

```bash
gh issue close 1 \
  --repo "[GITHUB_OWNER]/[GITHUB_REPO]" \
  --comment "Closing as completed. Azure Container App deployment succeeded and the live URL is reachable."
```

## Quick Sanity Checks

```bash
# Confirm secrets exist
gh secret list --repo "[GITHUB_OWNER]/[GITHUB_REPO]"

# Confirm workflow exists
gh workflow list --repo "[GITHUB_OWNER]/[GITHUB_REPO]"

# Confirm open issues
gh issue list --repo "[GITHUB_OWNER]/[GITHUB_REPO]" --state open
```
