# Infrastructure Best Practices (LocalShop)

This document contains mandatory architectural decisions to prevent technical debt and "version lag."

## State Management
- **Mechanism:** Always use **Native S3 Locking** (`use_lockfile = true`).
- **Avoidance:** Do NOT use Amazon DynamoDB for state locking unless explicitly required for legacy reasons.
- **Security:** Ensure `encrypt = true` and `versioning = true` are set on the S3 bucket.

## Versioning Standards
- **Discovery:** Never use hardcoded versions from memory. Always run `scripts/update_module_versions.cjs` to fetch the latest stable release.
- **Locking:** All versions in `providers.tf` and `main.tf` must be **strictly fixed** (e.g., `version = "1.2.3"`, NOT `version = "~> 1.2"`).

## Network & Compute
- **Isolation:** Follow the `vpc-spec.md` 3-tier architecture.
- **Encryption:** All storage (EBS, RDS, S3) must be encrypted at rest using KMS.
- **IAM:** Use IRSA (IAM Roles for Service Accounts) for all Kubernetes-based permissions.
