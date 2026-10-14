# Azure Resource Details

> Provisioned for **Azure Container Apps Setup** (Issue #1) on 2026-10-14.

| Property | Value |
|---|---|
| **Subscription** | `ms-non-prod-subscription-burak` (`44fbc5bb-2b98-4d5e-a58c-e2f2e4fae5d6`) |
| **Resource Group** | `rg-ghcp-demo` |
| **Container App Name** | `ghcp-demo-app` |
| **Container Apps Environment** | `ghcp-demo-env` |
| **Container Registry Name** | `ghcpdemoregistry` |
| **ACR Login Server** | `ghcpdemoregistry.azurecr.io` |
| **Region** | `swedencentral` |
| **Live URL** | https://ghcp-demo-app.redhill-e2ca4422.swedencentral.azurecontainerapps.io |
| **Ingress FQDN** | `ghcp-demo-app.redhill-e2ca4422.swedencentral.azurecontainerapps.io` |
| **Deployed Image** | `ghcpdemoregistry.azurecr.io/ghcp-demo-site:f792e13` |
| **Workflow Run** | https://github.com/mburakunuvar/dryrun-1410/actions/runs/38616930548 |

GitHub Actions authenticates through OIDC without an Azure client secret. The Container App uses its system-assigned managed identity with `AcrPull`; the deployment identity has `AcrPush` on the registry and `Container Apps Contributor` on the resource group.
