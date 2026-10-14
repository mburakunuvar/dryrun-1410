# template-azureapp.md

Purpose: Reusable template to resolve Issue #1 (Azure Container Apps Setup) without modifying unrelated repository files.

## Scope Guardrails

- Do not edit content pages while completing Issue #1.
- Focus only on Azure infrastructure setup, GitHub OIDC, workflow execution, verification, and `azure_resource.md`.
- Do not create or store an Azure client secret or ACR admin credentials.

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
- [GITHUB_BRANCH]: Federated branch (example: main)
- [WORKFLOW_NAME]: Azure Container Apps CI/CD

## Runbook (Issue #1)

1. Create the resource group, Basic ACR, and Container Apps environment.
2. Bootstrap the Container App with a public image and system-assigned identity; grant that identity `AcrPull` on ACR and configure the app to use that identity.
3. Create an Entra application/service principal for GitHub Actions and federate only the selected repository branch with OIDC.
4. Grant the GitHub deployment principal `Container Apps Contributor` on the resource group and `AcrPush` on the registry.
5. Configure the GitHub repository secrets and variables listed below. Do not create or store an Azure client secret or ACR admin credentials.
6. Trigger workflow [WORKFLOW_NAME] from the federated branch.
7. Wait for workflow completion and verify the live URL responds with HTTP 200.
8. Update `azure_resource.md` with actual values.

## Provisioning and OIDC Setup (PowerShell)

Run from PowerShell with `az` authenticated as an identity allowed to create the resources and role assignments, and `gh` authenticated with permission to manage repository secrets and variables.

```powershell
$subscriptionId = "[SUBSCRIPTION_ID]"
$resourceGroup = "[RESOURCE_GROUP]"
$location = "[LOCATION]"
$acrName = "[ACR_NAME]"
$environment = "[CONTAINERAPPS_ENV]"
$appName = "[CONTAINER_APP_NAME]"
$repo = "[GITHUB_OWNER]/[GITHUB_REPO]"
$branch = "[GITHUB_BRANCH]"

az account set --subscription $subscriptionId
az group create --name $resourceGroup --location $location
$resourceGroupId = az group show --name $resourceGroup --query id -o tsv

az acr create --name $acrName --resource-group $resourceGroup --sku Basic --admin-enabled false
$acrId = az acr show --name $acrName --resource-group $resourceGroup --query id -o tsv
$acrLoginServer = az acr show --name $acrName --resource-group $resourceGroup --query loginServer -o tsv
az acr config authentication-as-arm update --name $acrName --status enabled

az containerapp env create --name $environment --resource-group $resourceGroup --location $location

# Bootstrap the app identity with a public image, then grant it ACR read access.
az containerapp create --name $appName --resource-group $resourceGroup --environment $environment `
  --image mcr.microsoft.com/azuredocs/containerapps-helloworld:latest --ingress external --target-port 80 `
  --min-replicas 1 --max-replicas 1 --system-assigned
$appPrincipalId = az containerapp identity show --name $appName --resource-group $resourceGroup --query principalId -o tsv
az role assignment create --assignee-object-id $appPrincipalId --assignee-principal-type ServicePrincipal `
  --role AcrPull --scope $acrId
az containerapp registry set --name $appName --resource-group $resourceGroup --server $acrLoginServer --identity system

# Create a GitHub Actions identity without a client secret.
$app = az ad app create --display-name "ghcp-demo-github-actions" | ConvertFrom-Json
$clientId = $app.appId
az ad sp create --id $clientId
$federatedCredential = @{
  name = "github-$branch"
  issuer = "https://token.actions.githubusercontent.com"
  subject = "repo:{0}:ref:refs/heads/{1}" -f $repo, $branch
  audiences = @("api://AzureADTokenExchange")
} | ConvertTo-Json
$credentialFile = Join-Path $env:TEMP "github-federated-credential.json"
$federatedCredential | Set-Content -Path $credentialFile
az ad app federated-credential create --id $clientId --parameters $credentialFile
Remove-Item $credentialFile

$deploymentPrincipalId = az ad sp show --id $clientId --query id -o tsv
az role assignment create --assignee-object-id $deploymentPrincipalId --assignee-principal-type ServicePrincipal `
  --role "Container Apps Contributor" --scope $resourceGroupId
az role assignment create --assignee-object-id $deploymentPrincipalId --assignee-principal-type ServicePrincipal `
  --role AcrPush --scope $acrId

# Store identity IDs as secrets; keep non-sensitive deployment settings as variables.
$tenantId = az account show --query tenantId -o tsv
gh secret set AZURE_CLIENT_ID --body $clientId --repo $repo
gh secret set AZURE_TENANT_ID --body $tenantId --repo $repo
gh secret set AZURE_SUBSCRIPTION_ID --body $subscriptionId --repo $repo
gh variable set ACR_LOGIN_SERVER --body $acrLoginServer --repo $repo
gh variable set AZURE_RESOURCE_GROUP --body $resourceGroup --repo $repo
gh variable set AZURE_CONTAINERAPP_NAME --body $appName --repo $repo

# Start the workflow from the same branch as the federated credential.
gh workflow run "[WORKFLOW_NAME]" --repo $repo --ref $branch
```

## Deploy and Verify

```powershell
$runId = gh run list --repo "[GITHUB_OWNER]/[GITHUB_REPO]" --workflow "[WORKFLOW_NAME]" `
  --limit 1 --json databaseId --jq '.[0].databaseId'
gh run watch $runId --repo "[GITHUB_OWNER]/[GITHUB_REPO]" --interval 10
gh run view $runId --repo "[GITHUB_OWNER]/[GITHUB_REPO]" `
  --json conclusion,status,url,displayTitle,startedAt,updatedAt

$fqdn = az containerapp show --name "[CONTAINER_APP_NAME]" --resource-group "[RESOURCE_GROUP]" `
  --query "properties.configuration.ingress.fqdn" -o tsv
Invoke-WebRequest -Uri "https://$fqdn" -Method Head
```

## GitHub Configuration

**Repository secrets:** `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`.

**Repository variables:** `ACR_LOGIN_SERVER`, `AZURE_RESOURCE_GROUP`, `AZURE_CONTAINERAPP_NAME`.

The federated credential subject must exactly match the `sub` claim GitHub emits. Standard accounts use `repo:[GITHUB_OWNER]/[GITHUB_REPO]:ref:refs/heads/[GITHUB_BRANCH]`; Enterprise Managed User repositories may emit immutable owner/repository IDs such as `repo:<owner>@<id>/<repo>@<id>:ref:refs/heads/<branch>`. If Azure reports `AADSTS700213`, use the assertion subject from that error to create the matching federated credential. Do not add `AZURE_CLIENT_SECRET`, `ACR_USERNAME`, or `ACR_PASSWORD`; ACR admin access remains disabled.

## Completion Evidence (Paste Into Issue #1 Comment)

- Container App: [CONTAINER_APP_NAME]
- Container Apps Environment: [CONTAINERAPPS_ENV]
- ACR Login Server: [ACR_LOGIN_SERVER]
- Resource Group: [RESOURCE_GROUP]
- Live URL: https://[FQDN]
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
# Confirm configured deployment values without exposing credentials.
gh secret list --repo "[GITHUB_OWNER]/[GITHUB_REPO]"
gh variable list --repo "[GITHUB_OWNER]/[GITHUB_REPO]"
gh workflow list --repo "[GITHUB_OWNER]/[GITHUB_REPO]"
gh issue list --repo "[GITHUB_OWNER]/[GITHUB_REPO]" --state open
```
