# Azure Deployment Plan

> **Status:** Validated

Generated: 2026-10-14

## 1. Project Overview

**Goal:** Deploy this repository's static site as one externally accessible container on Azure Container Apps, publish the image to Azure Container Registry, run the existing GitHub Actions deployment workflow, and record the deployed resource details.

**Path:** Modernize Existing

## 2. Requirements

| Attribute | Value |
|---|---|
| Classification | POC / demo |
| Scale | Small (<1K users), single region |
| Budget | Cost-optimized |
| Compliance | No special constraints |
| Subscription | ms-non-prod-subscription-burak (`44fbc5bb-2b98-4d5e-a58c-e2f2e4fae5d6`) |
| Location | Sweden Central (`swedencentral`) |

**Authentication decision:** GitHub Actions will use OIDC/workload identity federation, not a client secret. The repository currently has no deployment secrets. The federated identity will be restricted to `repo:mburakunuvar/dryrun-1410:ref:refs/heads/main`.

**Azure Policy constraints:** Three subscription assignments were inspected. They concern Defender for SQL/Open Source Relational Databases and do not constrain this Container Apps/ACR deployment. No region, naming, or tag requirement relevant to these resources was found.

## 3. Components Detected

| Component | Type | Technology | Path |
|---|---|---|---|
| Demo site | Static website in a container | HTML served by `nginx:alpine`; listens on port 80 | Repository root |
| Container image | Container | Docker; copies repository HTML files into nginx | `Dockerfile` |
| Deployment pipeline | CI/CD | GitHub Actions, Azure CLI, Docker | `.github/workflows/azure-container-apps.yml` |
| Setup runbook | Documentation | Markdown | `template-azureapp.md`, `azure_resource.md` |

Existing Azure resources in the selected subscription: 10 resource groups; 0 ACR registries; 0 Container Apps managed environments; 0 Container Apps.

## 4. Recipe Selection

**Selected:** AZCLI

**Rationale:** Issue #1 explicitly specifies Azure CLI provisioning, and the repository already contains an Azure CLI-based GitHub Actions deployment workflow and runbook. Preserve that workflow shape while updating its authentication to OIDC and its registry access to role-based access.

## 5. Architecture

**Stack:** Containers

### Service Mapping

| Component | Azure Service | SKU / Configuration |
|---|---|---|
| Static website | Azure Container Apps | Consumption; external HTTP ingress; target port 80; 1 minimum and maximum replica |
| Container image | Azure Container Registry | Basic |
| Container Apps environment | Azure Container Apps managed environment | Sweden Central; default environment logging |
| GitHub Actions deployment identity | Microsoft Entra service principal with federated credential | OIDC subject restricted to the `main` branch |
| Container App image pull identity | Container App system-assigned managed identity | `AcrPull` scoped to the registry |

### Proposed Resource Names

| Resource | Name | Availability |
|---|---|---|
| Resource group | `rg-ghcp-demo` | Not present in selected subscription |
| Container registry | `ghcpdemoregistry` | Azure reported the global name available |
| Container Apps environment | `ghcp-demo-env` | No existing Container Apps environment in selected subscription |
| Container App | `ghcp-demo-app` | No existing Container App in selected subscription |

### Supporting Services and Access

| Service | Purpose |
|---|---|
| Log Analytics | Environment logging using the Container Apps environment default |
| GitHub OIDC | Short-lived federation for workflow login; no stored Azure client secret |
| Azure RBAC | GitHub deployment principal gets `Container Apps Contributor` scoped to the new resource group and `AcrPush` scoped to ACR; the app managed identity gets `AcrPull` scoped to ACR |

The workflow will use GitHub secrets for `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, and `AZURE_SUBSCRIPTION_ID`. Non-sensitive names and the ACR login server will be GitHub repository variables. Remove ACR username/password and Azure client-secret handling from the workflow and runbook.

## 6. Provisioning Limit Checklist

### Phase 1: Resource Inventory

| Resource Type | Number to Deploy | Total After Deployment | Limit/Quota | Notes |
|---|---:|---:|---|---|
| `Microsoft.Resources/resourceGroups` | 1 | 11 | 980 per subscription | 10 existing. Subscription-level limit; one new group remains within limit. |
| `Microsoft.ContainerRegistry/registries` | 1 | 1 | 100 per subscription (default) | 0 existing. `Microsoft.Quota` returned `BadRequest` for this provider; count from `az acr list`; limit from [Azure subscription and service limits](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/azure-subscription-service-limits). |
| `Microsoft.App/managedEnvironments` | 1 | 1 | 50 in Sweden Central | `ManagedEnvironmentCount`: quota 50, usage 0, from `az quota list` and `az quota usage list`. |
| `Microsoft.App/containerApps` | 1 | 1 | No separate applicable quota exposed | 0 existing; provider metadata confirms Sweden Central support; managed environment quota has capacity. |
| `Microsoft.OperationalInsights/workspaces` | 1 (environment logging) | 8 | 1,000 per subscription | 7 existing in the subscription (6 in Sweden Central); `Microsoft.Quota` returned `BadRequest` for this provider. The default subscription service limit is documented in [Azure Monitor limits](https://learn.microsoft.com/en-us/azure/azure-monitor/quotas#log-analytics-workspaces). |

**Capacity status:** Within the checked limits. Resource provider metadata lists Sweden Central for both `Microsoft.App/managedEnvironments` and `Microsoft.ContainerRegistry/registries`.

## 7. Execution Checklist

### Phase 1: Planning
- [x] Analyze workspace and existing deployment workflow
- [x] Gather classification, scale, budget, compliance, subscription, and location
- [x] Check subscription policies
- [x] Check regional support, resource counts, and quota/capacity
- [x] Select AZCLI recipe and Container Apps architecture
- [x] User approved this plan

### Phase 2: Execution (after approval)
- [x] Update the deployment workflow for GitHub OIDC and managed-identity ACR pull
- [x] Update the setup runbook and Issue #1 template for OIDC; remove password-based registry steps
- [x] Validate the workflow and runbook
- [ ] Provision the resource group, Basic ACR, Container Apps environment, and app
- [ ] Create the federated credential and scoped Azure role assignments
- [ ] Configure GitHub repository secrets/variables without exposing credentials
- [ ] Validate the Docker image locally if Docker is available
- [ ] Run the `Azure Container Apps CI/CD` workflow and verify its completion
- [ ] Verify the public URL responds successfully
- [ ] Record actual resource IDs, registry endpoint, environment/app names, region, and URL in `azure_resource.md`

### Phase 3: Validation
- [x] All validation checks pass
  - [x] 1. Core validation: Azure CLI installed/authenticated, selected subscription and region confirmed, workflow syntax checked
  - [x] 2. Docker image built successfully from the repository-root `Dockerfile`
  - [x] 3. Azure Policy validation for the selected subscription
  - [x] 4. GitHub Actions OIDC permissions, secret/variable references, and branch subject verified
  - [x] 5. Required Azure RBAC roles verified as assignable at the planned scopes

## 8. Validation Proof

| Check | Command Run | Result | Timestamp |
|---|---|---|---|
| Git diff integrity | `git diff --check` | Pass | 2026-10-14 20:15 +02:00 |
| Azure CLI and authentication | `az version`; `az account show` | Pass; Azure CLI 2.89.1, selected subscription enabled | 2026-10-14 20:15 +02:00 |
| Region and resource names | `az provider show`; `az acr check-name`; resource list queries | Pass; Sweden Central supported and proposed names unused | 2026-10-14 20:15 +02:00 |
| Workflow syntax and OIDC | Python YAML parse and assertions on `.github/workflows/azure-container-apps.yml` | Pass; `id-token: write`, no client secret or ACR password references | 2026-10-14 20:15 +02:00 |
| Docker build | `docker build --quiet --tag ghcp-demo-site:validation .` | Pass; image `sha256:98742833a23e429fcfa11e12a03502fa7c36f6c38b705d85ea37a4e77dfce5ae` | 2026-10-14 20:17 +02:00 |
| Azure policies | `az policy assignment list --disable-scope-strict-match` | Pass; subscription policies do not restrict Container Apps, ACR, location, or naming | 2026-10-14 20:15 +02:00 |
| Required RBAC roles | `az role definition list` for Container Apps Contributor, AcrPush, AcrPull | Pass; all required roles exist | 2026-10-14 20:15 +02:00 |

**Validated by:** azure-validate skill
**Validation timestamp:** 2026-10-14 20:15 +02:00

## 9. Role Assignment Verification

- **Status:** Verified
- **GitHub deployment identity:** `Container Apps Contributor` scoped to the resource group and `AcrPush` scoped to the registry.
- **Container App system identity:** `AcrPull` scoped to the registry.
- **Least privilege:** Registry data-plane roles are resource-scoped; the management-plane role is limited to the deployment resource group.
- **Source reviewed:** `template-azureapp.md` provisioning commands and `.github/workflows/azure-container-apps.yml` deployment operations.
