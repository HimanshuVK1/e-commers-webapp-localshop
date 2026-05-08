---
name: tf-plan
description: Run terraform init --upgrade then terraform plan and analyze the output for risks, warnings, and deprecations and fix them. Use before applying any infrastructure changes.
allowed-tools: run_shell_command, read_file, grep_search
disable-model-invocation: true
---

# tf-plan

Run `cd terraform && terraform plan -no-color` and perform a comprehensive analysis of the output.

## Analysis Requirements

You MUST summarize the following after execution:

### 1. Resource Delta
- Total count of resources to be **Added**, **Changed**, or **Destroyed**.

### 2. Warnings & Deprecations
- **Warnings:** Explicitly search for the `Warning:` prefix. Summarize what they are and their impact.
- **Deprecations:** Check for mentions of deprecated attributes, blocks, or functions.
- **Technical Debt:** Identify any suboptimal configurations flagged by the provider.

### 3. Risk Assessment
- **Resource Replacements:** Identify any resources with `-/+` (destroy and then create replacement). This is a critical risk for downtime or data loss.
- **Security Groups:** Identify changes to ingress/egress rules (check for `0.0.0.0/0` or broad ports).
- **IAM:** Identify changes to IAM roles or policies (verify principle of least privilege).

### 4. Blast Radius
- Estimate the scope of impact (e.g., "Network wide," "Service specific," "Security/IAM only").

### phase 5: Check Proper Connectivity between Modules and Cloud Resources or Services (The 'Testing' step)
1.  **MANDATORY:** You MUST run the `tf-plan` skill to validate the infrastructure changes before applying.
2.  Analyze the plan output for any risks, warnings, or deprecations.


## Post-Check Suggestions
Provide actionable suggestions based on the findings:
- How to resolve warnings or deprecations (e.g., suggest using `moved` blocks for renames).
- Security hardening recommendations for any flagged risks.
- Optimization tips if the plan looks complex.

## Error Handling
If the plan fails:
- Read the error log.
- Diagnose the root cause (e.g., missing variables, provider auth, syntax, version mismatch).
- Suggest a specific fix aligned with project standards in `AGENTS.md`.

