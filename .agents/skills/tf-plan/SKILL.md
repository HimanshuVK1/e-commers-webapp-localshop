---
name: tf-plan
description: Run terraform plan and analyze the output for risks. Use before applying any infrastructure changes.
allowed-tools: run_shell_command, read_file, grep_search
disable-model-invocation: true
---

# tf-plan

Run `cd terraform && terraform plan -no-color` and analyze the output for architectural and security risks.

## Analysis Requirements

You MUST summarize the following after execution:
1.  **Resource Delta:** Total count of resources to be Added, Changed, or Destroyed.
2.  **Risk Assessment:**
    - Are there any **Resource Replacements**? (Critical risk of downtime or data loss).
    - Are there **Security Group** changes? (Check for overly permissive ingress).
    - Are there **IAM** policy changes? (Verify least privilege).
3.  **Blast Radius:** Estimate the scope of impact (e.g., "Network wide," "Service specific," or "Compute only").

## Error Handling
If the plan fails:
- Read the error log.
- Diagnose the root cause (e.g., missing variables, provider auth, syntax).
- Suggest a specific fix from the `GEMINI.md` or `scaffold-terraform` references.
