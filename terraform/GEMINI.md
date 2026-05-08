# Terraform Engineering Standards & Best Practices

This directory contains the infrastructure code for LocalShop. All agents and engineers MUST adhere to these generic standards for EVERY task to ensure stability and prevent recurring errors.

## 1. Verification-First Workflow
- **No Assumptions:** Never assume a variable or resource behaves the same across different versions of a module.
- **Mandatory Documentation Review:** Before using or upgrading a community module, use `web_fetch` to read the official `UPGRADE.md`, `CHANGELOG.md`, or the latest README on the provider/module's GitHub repository.
- **API Compliance:** Always cross-reference variable names with the specific version pinned in the project (e.g., EKS v21.x vs v20.x).

## 2. Dependency & Architecture Mapping
- **Hidden Dependencies:** For complex architectures (like Private VPCs, EKS Clusters, or Multi-Region setups), proactively map "software" dependencies (like EKS Add-ons) and "routing" dependencies (like VPC Endpoints).
- **Service Integration:** Verify that cross-service permissions (IAM/KMS) are explicitly granted for integrated services (e.g., CloudWatch Logs using KMS keys).

## 3. Immediate Deep Diagnostics (Failure Protocol)
- **Do Not Guess:** If a resource fails to create or update, DO NOT attempt to "reason" a fix.
- **Raw API Inspection:** Immediately use the relevant Cloud CLI (e.g., `aws eks describe-*`, `aws rds describe-*`) to retrieve the exact error code, health issues, and conditions from the cloud provider.
- **Log Review:** Check bootstrap logs (Cloud-init) or system logs (Kubelet/Systemd) if the failure involves compute resources.

## 4. Static Analysis & Validation
- **Pre-Apply Checks:** Always prefer running a `terraform plan` and reviewing it against known cloud constraints before executing an apply.
- **Cost & Security:** Maintain cost-effective choices (e.g., single NAT Gateway for dev) while ensuring enterprise security standards (e.g., Private Endpoints, non-public subnets).

## 5. Persistence of Knowledge
- If a specific configuration "gotcha" is discovered (like ECR lifecycle priority rules), it must be documented here briefly to prevent regression during future scaling.
