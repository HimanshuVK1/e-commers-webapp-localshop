---
name: scaffold-static-site
description: Generate complete Terraform infrastructure for S3 + CloudFront static site hosting. Use when setting up a new project or regenerating infrastructure files.
allowed-tools: run_shell_command, read_file, write_file, grep_search, glob
disable-model-invocation: true
argument-hint: "[aws-region] [project-name]"
---

# scaffold-static-site

Generate a complete Terraform configuration for deploying a static website to AWS using S3 + CloudFront.

Use $ARGUMENTS for optional overrides:
- $0 = AWS region (default: ap-south-1)
- $1 = Project name (default: portfolio-site)

## What to Generate

Read `template-spec.md` in this skill folder for the full infrastructure specification.

Generate all files in the `terraform/` directory following the template spec. Use the arguments provided to customize the `variables.tf` and `main.tf` logic.

## After Generation

- [ ] List all files created
- [ ] Show a summary of resources that will be provisioned
- [ ] Remind the engineer to review the files and run `terraform plan` when ready
