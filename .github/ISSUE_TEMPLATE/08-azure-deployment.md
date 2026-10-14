---
name: "Issue 8 — Azure Deployment"
about: "Deploy the full site to Azure Container Apps and verify it is live"
title: "Azure Deployment"
labels: "copilot-cli"
---

## Task
Deploy the full site to Azure Container Apps and verify it is live.

## Pre-flight requirements
1. **Azure Container Apps Setup** (Issue 1) must be completed — environment and app created, GitHub OIDC configured, and required repository secrets/variables set.
2. All page issues (Issues 2–7) should be closed — Home Page, Web UI, VS Code, CLI, SDK, and App pages are committed and pushed to `main`.

## Steps

### 1. Verify pre-flight
```bash
gh issue list --state open --json number,title,labels \
  --jq '.[] | select(any(.labels[]; .name == "copilot-cli" or .name == "coding-agent" or .name == "agent-mode")) | "#\(.number) \(.title)"'
```
If any page issues (2–7) are still open, wait or resolve them first.

### 2. Ensure latest code is on main
```bash
git pull --rebase origin main
```

### 3. Trigger the deployment workflow
```bash
gh workflow run "Azure Container Apps CI/CD"
```

### 4. Wait for the workflow to complete
```bash
sleep 10
gh run list --workflow="Azure Container Apps CI/CD" --limit 1 --json status,conclusion,databaseId
```
If status is `in_progress`, wait and re-check. If conclusion is `failure`, inspect logs:
```bash
gh run view <run-id> --log-failed
```

### 5. Retrieve and verify the live URL
```bash
gh run view <run-id> --log | grep "Live URL"
```
Then open the URL and confirm the home page and all navigation links work.

## Common failure causes
- **Azure login failure**: Verify `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, and `AZURE_SUBSCRIPTION_ID`, plus the GitHub OIDC federated credential's subject, issuer, and audience.
- **ACR login failure**: Verify the GitHub principal has `AcrPush` and the app managed identity has `AcrPull`; ACR admin access should remain disabled.
- **Container App not found**: Complete the resource and identity bootstrap in Issue #1 before running this deployment workflow.

## Assigned to
GitHub Copilot CLI

## Completion
Once deployment is verified and the live site is confirmed working, close this issue:
```bash
gh issue close <this-issue-number>
```
