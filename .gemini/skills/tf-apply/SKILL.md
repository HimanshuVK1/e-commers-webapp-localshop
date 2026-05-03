---
name: tf-apply
description: Run terraform apply to create or update AWS infrastructure. Use ONLY after reviewing and approving a terraform plan.
---

# Terraform Apply

Run the following command in the `terraform` directory to apply the configuration:
```powershell
terraform apply -auto-approve -no-color "tfplan"
```

## Post-Apply Checklist
After the apply completes, perform these steps:
- [ ] **Show Key Outputs:** Display any important outputs that are not marked as `sensitive`, such as resource IDs or endpoints.
- [ ] **Verify Deployment:** Check if the infrastructure is "Deployed" or "Available".
- [ ] **Report Errors:** If any resource fails to create, report the specific error and suggest a fix.

## Critical Constraints
- **No Auto-Retry:** If apply fails, do NOT retry automatically. Show the error and wait for user instructions.
- **Sensitive Data:** Do not print any outputs marked as `sensitive` in the console.
- **Tooling:** Prefer using standard CLI tools (Terraform, AWS CLI) for verification.
