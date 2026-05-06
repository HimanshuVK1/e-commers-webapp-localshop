---
name: scaffold-terraform
description: Advanced AWS infrastructure management using modular Terraform. Use when creating or modifying modular AWS resources (VPC, EKS, RDS, etc.) to ensure adherence to LocalShop architectural standards.
---

# Terraform Expert
# scaffold-terraform

## 🔴 PERMISSION GATE
**disable-model-invocation: true**
- **CRITICAL:** Do NOT run or activate this skill on your own.
- **MANDATE:** You MUST identify this skill to the user and ask for explicit permission before using any of its workflows or assets.

## Core Directives


1.  **Modularity:** Always create resources within `terraform/modules/<service-name>/`.
2.  **Verified Modules:** Exclusively use community modules from **`terraform-aws-modules/*`** for major infrastructure components (e.g., EKS, VPC, RDS).
3.  **Native Resource Preference:** If a community module consistently triggers deprecation warnings, maintenance overhead, or violates security standards, you MUST refactor to native Terraform resources to ensure long-term stability.
4.  **File Consistency:** Every module MUST have exactly `main.tf`, `variables.tf`, and `outputs.tf`.
5.  **Connectivity:** Connect modules only via variables and outputs.
6.  **Versioning:** Fix all provider and module versions to specific releases (commit hashes).
7.  **VPC Endpoints & Service Bootstrapping:** When implementing custom VPC Endpoint policies (e.g., S3 Gateway), you MUST explicitly whitelist the hidden, service-owned buckets or endpoints required for resource bootstrapping (e.g., `amazon-eks-*` for EKS nodes, or specific regional buckets for other AWS services). Overtightening endpoint policies causes silent communication failures, resulting in infinite "Still creating..." timeout loops during infrastructure provisioning.

## Tooling & Discovery

To maintain the infrastructure, use the following tools:
- **`run_shell_command` (bash):** Execute `terraform fmt` after every edit. Use `terraform init` and `validate` to check new modules.
- **`grep_search` / `glob`:** Use to discover dependencies between modules (e.g., finding where an `output` is used as a `variable`).
- **`read_file` / `write_file` / `replace`:** Use for precise, surgical edits to Terraform configuration files.

## Recipe Card: Modular Scaffolding Workflow

You MUST execute the following phases in sequence. Do not skip steps.

### Phase 1: Discovery (The 'Research' step)
1.  Verify if the service exists in `terraform/modules/`.
2.  Consult `references/naming-conventions.md` to determine the resource name.
3.  **Policy Check:** Read and follow **`references/best-practices.md`** for state locking and versioning rules.
4.  **CLI Version Check:** Use my internal search/script to find the latest stable Terraform CLI version and pin it in the root `providers.tf`.
4.  **Architecture Check:** You MUST read and follow the relevant specification file before acting:
    - **VPC:** `references/vpc-spec.md` (3-tier architecture).
    - **EKS:** `references/eks-spec.md` (Security & IRSA).
    - **RDS:** `references/rds-spec.md` (Subnet isolation & HA).
5.  Check root `outputs.tf` for any existing resources this new module depends on.
6.  **Backend Check:** If this is a new root environment, check for `backend.tf`. Use **Native S3 Locking** (`use_lockfile = true`) for the state.

### Phase 2: Scaffolding (The 'Act' step)
1.  **DELEGATION MANDATE:** You MUST delegate the actual code generation to the `tf-writer` sub-agent.
2.  Use the `invoke_agent` tool. Set `agent_name` to `tf-writer`.
3.  In your prompt to `tf-writer`, provide:
    - The target service name.
    - The exact module version obtained from the script.
    - The required variables and outputs based on the architecture specs.
    - Explicit instruction to create the `main.tf`, `variables.tf`, and `outputs.tf` files in `terraform/modules/<service-name>/`.
4.  **Root Setup:** If configuring a new environment, manually copy `assets/backend.tf.tmpl` to the root `terraform/` directory.

### Phase 3: Dependency Linking (The 'Integration' step)
1.  After `tf-writer` completes, verify the new module's `variables.tf`.
2.  Map those variables to outputs from existing modules in the root `main.tf`.
3.  Ensure the new module exports required identifiers (ID/ARN) in its `outputs.tf`.

### Phase 4: Validation (The 'Sign-off' step)
1.  Run `terraform fmt` on the new module.
2.  Provide a Status Report:
    - **Action:** Created/Modified [Service Name].
    - **Links:** Mapped [X] inputs to [Y] outputs.
    - **Security:** Verified non-root and distroless alignment.

### Phase 5: Security Posture (The 'Compliance' step)
1.  **MANDATORY:** You MUST activate and run the **`terraform-config-infra-scanner`** skill on the `terraform/` directory.
2.  Review any FAILED checks.
3.  If critical vulnerabilities are found, you MUST fix them using the **`security-auditor`** subagent before finishing the task.

## References
- Refer to `references/naming-conventions.md` for resource naming rules.
