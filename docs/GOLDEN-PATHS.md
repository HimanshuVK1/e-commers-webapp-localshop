# Golden Paths – LocalShop Internal Developer Platform

**Purpose:** Standardized, secure, and fast workflows for common developer tasks.

## 1. New Microservice Golden Path (Recommended)

### Steps

1. **Create new service repository** (or use monorepo structure)
2. **Use provided Helm chart template** (located in `/helm/`)
3. **Add ArgoCD Application manifest** in `argocd/applications/`
4. **Raise PR to `main`** → ArgoCD automatically syncs
5. **Secrets are injected automatically** via External Secrets Operator

### Example Commands

```bash
git checkout -b feature/new-payment-service
# Copy template
cp -r helm/templates/microservice-template/* services/payment/
# Update values
# Commit + PR
```

**Time to Production:** ~15 minutes (after first setup)

## 2. Self-Service RDS Database Provisioning

1. Use Terraform module: `terraform/modules/rds/`
2. Create a `claim` file in `crossplane/claims/` (or Terraform plan)
3. Raise PR → Infrastructure is provisioned automatically
4. Connection details injected into your service via ESO

## 3. GPU Workload Deployment (AI/ML)

- Use the NVIDIA GPU Operator enabled EKS node groups
- Deploy via Helm chart with GPU resource requests
- Monitored via DCGM exporter

## 4. AI Agent-Assisted Operations

You can use the Gemini CLI + GitHub MCP to:
- Generate Terraform code
- Review security posture (Checkov)
- Create branches and PRs automatically

Example prompt:
> "Create a new golden path for a Node.js microservice with Redis cache"

## Benefits of Following Golden Paths

- Consistent security posture
- Reduced onboarding time for new developers
- Lower operational toil for platform team
- Built-in observability and rollback

---

*All golden paths are enforced with policy-as-code where possible.*