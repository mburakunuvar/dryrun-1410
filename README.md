<!-- TEMPLATE_README_START -->
> [!NOTE]
> **This repository is a template.** Click the button below to create your own copy and run the demo yourself.
> The template explanation you're reading now will be **automatically removed** from your new repository.

<a href="https://github.com/mburakunuvar/gh-copilot-JUNE26-LIVE-DEMO-DONT-DELETE/generate">
  <img src="https://img.shields.io/badge/%F0%9F%9A%80-Use%20This%20Template-2ea44f?style=for-the-badge" alt="Use This Template">
</a>

---
<!-- TEMPLATE_README_END -->

# GitHub Copilot Across Multiple Modes

A hands-on demo showcasing **GitHub Copilot across multiple modes** — CLI, Agent Mode (IDE), Coding Agent (Web UI), and Custom Agents — building, deploying, and managing a mini web application driven entirely by GitHub Issues.

---

## About This Demo

This demo walks through a realistic developer workflow driven entirely by GitHub Issues. Each issue is assigned to a different Copilot mode — **Copilot CLI**, **Agent Mode (IDE)**, **Coding Agent (Web UI)**, or a **Custom Agent** — demonstrating how they collaborate across a single project. Once all pages are built, an automated workflow triggers deployment to Azure.

By the end of the demo, a small web app has been:
- **Built** (home page + five child pages, each tackled by a different Copilot mode)
- **Audited** by a custom infrastructure agent
- **Deployed** to Azure Container Apps via CI/CD

### Content Pages

| Page | Topic | Source |
|---|---|---|
| **Home** (`index.html`) | Welcome to GH Copilot — overview with navigation to all child pages | — |
| **GH Copilot in VS Code** (`gh-copilot-vscode.html`) | Copilot agent concepts in VS Code | [How AI works in VS Code](https://code.visualstudio.com/docs/agents/concepts/overview) |
| **GH Copilot in Web UI** (`gh-copilot-web-ui.html`) | Cloud agent and code review in GitHub | [About GitHub Copilot cloud agent](https://docs.github.com/en/copilot/concepts/agents/cloud-agent/about-cloud-agent), [About GitHub Copilot code review](https://docs.github.com/en/copilot/concepts/agents/code-review) |
| **GH Copilot CLI** (`gh-copilot-cli.html`) | Using Copilot from terminal workflows | [Using GitHub Copilot CLI](https://docs.github.com/en/copilot/how-tos/copilot-cli/use-copilot-cli/overview) |
| **GH Copilot SDK** (`gh-copilot-sdk.html`) | Integrating Copilot into apps and services | [github/copilot-sdk](https://github.com/github/copilot-sdk?utm_source=blog-cli-sdk-repo-cta&utm_medium=blog&utm_campaign=cli-sdk-jan-2026) |
| **GH Copilot App** (`gh-copilot-app.html`) | Releases and issues for Copilot app | [github/app](https://github.com/github/app) |

---

## Prerequisites

Before running this demo, make sure the following are in place:

- A GitHub repository with **10 issues** (see [Getting Started](#getting-started) below to create them)
- **GitHub Copilot** enabled on the account and the repository
- **Copilot CLI** installed and authenticated — verify with `gh auth status`
- **VS Code** with Copilot Agent Mode for IDE-based issues
- **GitHub.com** access for Coding Agent (Web UI) issues

> 🎬 **The live demo starts at Issue 1.** All issues are worked through during the demo.

---

## Getting Started

After creating a new repo from this template, the **10 demo issues are not created automatically** — GitHub does not trigger workflows on the initial commit from a template.

Run this command once to seed all issues and labels:

```bash
gh workflow run "Setup Demo Issues" --repo <owner>/<your-new-repo>
```

After ~30 seconds, verify the issues were created:

```bash
gh issue list --repo <owner>/<your-new-repo>
```

> 💡 You can also trigger the workflow from the **Actions** tab → **Setup Demo Issues** → **Run workflow**.

---

## Demo Scenarios

### Issue 1 — Azure Container Apps Setup
**Label**: `init-demo`

Create Azure Container Registry and Container Apps resources, add deployment secrets, and verify the live URL. The deployment workflow is `workflow_dispatch` only — trigger it manually after setup to deploy the container.

---

### Issue 2 — Scaffold and Beautify the Home Page
**Label**: `copilot-cli`

Scaffold and beautify `index.html` as a **Welcome to GH Copilot** overview page with five navigation buttons linking to these child pages: GH Copilot in VS Code, GH Copilot in Web UI, GH Copilot CLI, GH Copilot SDK, GH Copilot App.

---

### Issue 3 — GH Copilot in Web UI Page
**Label**: `coding-agent`

Build a child page for GH Copilot in Web UI. Follows the same structure and style as the home page. Assigned to Cloud Agent on GitHub.com.

---

### Issue 4 — GH Copilot in VS Code Page
**Label**: `agent-mode`

Build a child page for GH Copilot in VS Code. Follows the same structure and style as the home page. Assigned to Copilot Agent Mode (IDE).

---

### Issue 5 — GH Copilot CLI Page
**Label**: `copilot-cli`

Build a child page for GH Copilot CLI. Follows the same structure and style as the home page.

---

### Issue 6 — GH Copilot SDK Page
**Label**: `copilot-cli`

Build a child page for GH Copilot SDK. Follows the same structure and style as the home page.

---

### Issue 7 — GH Copilot App Page
**Label**: `copilot-cli`

Build a child page for GH Copilot App. Follows the same structure and style as the home page.

---

### Issue 8 — Azure Deployment
**Label**: `copilot-cli`

> **⚠️ Prerequisite**: Issues #2–#7 must be closed before deployment. Issue #1 (Azure Container Apps Setup) must be completed first.

Verify all page issues are closed, then trigger the deployment workflow. The `auto-deploy.yml` workflow can also trigger this automatically when the last page issue and Azure Infra Review are closed.

---

### Issue 9 — Azure Infra Review
**Label**: `aca-infra-auditor`

Run an Azure Container Apps infrastructure review using the custom agent `aca-infra-auditor.agent`, then capture short, actionable recommendations.

---

### Issue 10 — Clean Up Azure Resources
**Label**: `post-demo`

After the demo is complete, delete all Azure resources (Resource Group, Container App, Container Registry) to avoid unnecessary costs.

---

## Multi-Mode Workflow & Auto-Deploy

Issues are spread across four Copilot modes, demonstrating how they work together:

| Mode | Label | Issues |
|---|---|---|
| **Copilot CLI** | `copilot-cli` | 2, 5, 6, 7, 8 |
| **Agent Mode (IDE)** | `agent-mode` | 4 |
| **Coding Agent (Web UI)** | `coding-agent` | 3 |
| **Custom Agent** | `aca-infra-auditor` | 9 |

The `auto-deploy.yml` workflow watches for issue closures. When all six page issues (2–7) are closed, it automatically triggers the Azure Container Apps CI/CD deployment (Issue 8). Azure Infra Review (Issue 9) is run manually after deployment is verified.

---

## Quick Reference

| Issue | Task | Label |
|---|---|---|
| 1 | Azure Container Apps Setup | `init-demo` |
| 2 | Scaffold & Beautify Home Page | `copilot-cli` |
| 3 | GH Copilot in Web UI Page | `coding-agent` |
| 4 | GH Copilot in VS Code Page | `agent-mode` |
| 5 | GH Copilot CLI Page | `copilot-cli` |
| 6 | GH Copilot SDK Page | `copilot-cli` |
| 7 | GH Copilot App Page | `copilot-cli` |
| 8 | Azure Deployment | `copilot-cli` |
| 9 | Azure Infra Review | `aca-infra-auditor` |
| 10 | Clean Up Azure Resources | `post-demo` |

---

## Repo Contents

| File | Description |
|---|---|
| `README.md` | This file |
| `Dockerfile` | Container image definition for Azure Container Apps deployment |
| `index.html` | Home page — GitHub Copilot overview with navigation |
| `gh-copilot-vscode.html` | Child page — GH Copilot in VS Code |
| `gh-copilot-web-ui.html` | Child page — GH Copilot in Web UI |
| `gh-copilot-cli.html` | Child page — GH Copilot CLI |
| `gh-copilot-sdk.html` | Child page — GH Copilot SDK |
| `gh-copilot-app.html` | Child page — GH Copilot App |
| `template-azureapp.md` | Reusable runbook for Azure Container Apps setup (Issue #1) |
| `azure_resource.md` | Azure resource details (filled in during Issue #1) |
| `.github/workflows/setup-issues.yml` | Creates issues and labels — trigger manually after using the template (see [Getting Started](#getting-started)) |
| `.github/workflows/azure-container-apps.yml` | Manual-trigger deployment to Azure Container Apps |
| `.github/workflows/auto-deploy.yml` | Auto-triggers deployment when all page issues (2–7) are closed |
| `.github/agents/aca-infra-auditor.agent.md` | Custom agent for auditing Azure Container Apps deployments |
