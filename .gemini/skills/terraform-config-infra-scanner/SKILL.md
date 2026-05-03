---
name: terraform-config-infra-scanner
description: Executes infrastructure security scans specifically using Checkov for Terraform. Use when asked to audit or scan Terraform files.
---

# Infrastructure Scanner (Checkov)

This skill focuses strictly on Terraform security compliance using Checkov.

## Workflow

### 1. Tool Check
Verify if Checkov is available:
- **Command:** `checkov --version`
- **If missing:** Inform the user to install it via `pip install checkov`.

### 2. Execution
Scan the `terraform/` directory for security and compliance issues:
```bash
checkov -d terraform/ --output json --quiet --no-guide
```

### 3. Triage & Delegation
1. Capture the Checkov JSON output.
2. Filter for **FAILED** checks, prioritizing **HIGH** and **CRITICAL** severity.
3. Pass the filtered results to the **`@security-auditor`** subagent for code fix generation.
   - Example: `@security-auditor Checkov found 3 failures in our VPC module. Here is the JSON. Please provide the remediated Terraform code.`

## Guidelines
- Focus exclusively on Terraform files.
- Never output raw scanner JSON to the main chat; always summarize or delegate.
- Use the `run_shell_command` tool for execution.
