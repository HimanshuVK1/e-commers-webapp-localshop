# Golden Paths - LocalShop IDP

**Golden Paths** are the opinionated, recommended, and supported ways to perform common tasks in the platform. Following them ensures speed, security, and consistency.

## 1. New Microservice (Primary Golden Path)

**Goal:** Scaffold and deploy a new microservice quickly and compliantly.

1. Go to **Backstage Developer Portal**
2. Use the `new-microservice` template
3. Fill in service details (name, language, team, etc.)
4. Template automatically creates:
   - Repository structure
   - Helm chart
   - ArgoCD Application
   - Proper labels & annotations
5. Push code → ArgoCD deploys automatically

**Backstage Template Location:** `backstage/templates/new-microservice/`

## 2. Infrastructure Provisioning (EKS / RDS / VPC)

1. Use reusable **Terraform modules** in `terraform/modules/`
2. Configure via `variables.tf` or claims (future Crossplane)
3. Submit PR → Infrastructure is provisioned via CI/CD

## 3. Secrets Management

- Never commit secrets
- Use **External Secrets Operator** + AWS Secrets Manager
- IRSA is configured for secure pod-to-AWS access

## 4. Security & Compliance

- All IaC scanned with **Checkov**
- Policy-as-Code enforced via **Kyverno** (coming soon)
- Guardrails applied automatically

## Benefits

- **Consistency** across all services
- **Security by default**
- **Faster delivery** (minutes instead of days)
- **Reduced support load** on platform team

---

*All golden paths are designed to be self-service and auditable.*
