# Agentic DevOps: Using MCP Servers

This project is configured for **Agentic DevOps**. This means that AI coding assistants (like Gemini, Cline, Cursor, or Amazon Q) are natively empowered to interact with your AWS EKS infrastructure and your GitHub repository.

We achieve this using the **Model Context Protocol (MCP)**. MCP provides standardized, secure APIs that allow LLMs to take actions on your behalf.

---

## 🛠 1. How to Make It Ready to Use

Before an AI assistant can perform actions, it needs access to your secure configuration and tokens.

### Step 1: Install `uv`
The Amazon EKS MCP Server runs via `uvx` (a fast Python tool runner). You must have `uv` installed on your machine.
- **Mac/Linux:** `curl -LsSf https://astral.sh/uv/install.sh | sh`
- **Windows:** `powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"`

### Step 2: Configure Environment Variables
We enforce a strict security mandate: **No tokens in code.**
Before opening your AI assistant, export your GitHub Personal Access Token (PAT) in your terminal. This token needs `repo` and `workflow` scopes.

**Linux/Mac:**
```bash
export GITHUB_PERSONAL_ACCESS_TOKEN="ghp_your_fine_grained_token_here"
```

**Windows (PowerShell):**
```powershell
$env:GITHUB_PERSONAL_ACCESS_TOKEN="ghp_your_fine_grained_token_here"
```

### Step 3: Link the Settings File
Point your AI assistant (e.g., Cline or Cursor) to the `cline_mcp_settings.json` file located in the root of this repository. This file contains the configuration that tells the AI how to launch the EKS and GitHub MCP servers.

---

## 🤖 2. Day-to-Day Tasks & Examples

Once configured, you can talk to your AI assistant in natural language to manage complex DevOps tasks.

### Scenario A: CI/CD Pipeline Debugging (GitHub MCP)
Instead of switching to your browser to check why a GitHub Action failed, ask the AI directly.

> **Prompt:** *"The 'Build and Push Microservices' GitHub Action just failed on the `dev` branch. Fetch the logs for the failed step, tell me which service failed to build, and suggest a fix for the Dockerfile."*

**What the AI does:**
1. Uses the GitHub MCP to list recent workflow runs.
2. Identifies the failed run and downloads the raw logs.
3. Analyzes the stack trace, identifies the error (e.g., a missing npm package in `webapp/frontend/Dockerfile`).
4. Writes the fix directly in your editor.

### Scenario B: EKS Troubleshooting (AWS EKS MCP)
When an alert fires in Grafana indicating a pod crash, you don't need to manually run `kubectl`.

> **Prompt:** *"The `cart-service` pods in the `localshop` namespace are in CrashLoopBackOff. Check their pod status, fetch the last 50 lines of logs from the failing container, and tell me if it's related to the Redis connection."*

**What the AI does:**
1. Uses the EKS MCP to list pods in the `localshop` namespace.
2. Identifies the failing `cart-service` pod.
3. Fetches the pod logs and Kubernetes events.
4. Reads the log (e.g., "Connection refused to localshop-platform-redis") and confirms the Redis issue.

### Scenario C: Repository Management (GitHub MCP)
Automate routine repository maintenance.

> **Prompt:** *"Check for any open PRs in this repository that have failing CI checks. Summarize the errors for me."*
> 
> **Prompt:** *"Search the codebase for any hardcoded 'TODO' comments and create a single GitHub Issue listing all of them."*

### Scenario D: Cluster Scaling & Auditing (AWS EKS MCP)
*(Note: Because we enabled `--allow-write` in the MCP settings, the AI can perform mutating actions.)*

> **Prompt:** *"We are expecting a traffic spike. Draft the command to increase the desired capacity of our EKS spot node group to 5 nodes. Let me review it before you execute."*
> 
> **Prompt:** *"List all Services of type `LoadBalancer` in the cluster. Are there any that don't have active pods behind them? I want to delete idle load balancers to save costs."*

---

## 🔒 Security Best Practices
- The AI acts using *your* AWS and GitHub credentials. Ensure your local terminal's AWS profile (`aws configure`) and your `GITHUB_PERSONAL_ACCESS_TOKEN` adhere to the **Principle of Least Privilege**.
- The `cline_mcp_settings.json` explicitly grants the EKS MCP server `--allow-write` and `--allow-sensitive-data-access`. Always review the AI's proposed actions before confirming execution if you are modifying production infrastructure.