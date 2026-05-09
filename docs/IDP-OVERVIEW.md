# Internal Developer Platform (IDP) Overview - LocalShop

**Status:** MVP | **Branch:** `feature/idp-enhancements`

## What is This Project?

This is the foundation of an **Internal Developer Platform (IDP)** designed to provide developers with **self-service, opinionated, and secure** ways to build and deploy microservices on AWS EKS.

Instead of every developer managing their own infrastructure, this platform offers **golden paths** and abstractions so they can focus on delivering business value.

## Core Principles

- **Platform as a Product** — Treat the IDP as an internal product for developers
- **Golden Paths** — Standardized, well-supported, secure-by-default workflows
- **Self-Service** — Minimize tickets and manual work
- **Cognitive Load Reduction** — Abstract complexity away from application teams
- **Security & Compliance by Default** — Shift-left with Policy-as-Code

## Key Components

| Component                    | Tool / Technology                  | Status     |
|------------------------------|------------------------------------|------------|
| Developer Portal             | Backstage                          | Implemented |
| Infrastructure as Code       | Terraform                          | Mature     |
| GitOps Delivery              | ArgoCD + Helm                      | Mature     |
| Secrets Management           | External Secrets + AWS SM + IRSA   | Mature     |
| Policy Enforcement           | Checkov + Kyverno (planned)        | In Progress|
| AI Agent Layer               | GitHub MCP + Gemini CLI            | Implemented |

## Benefits Delivered

- Significantly reduced time to provision new environments and services
- Consistent security and compliance posture across all workloads
- Lower operational toil for both platform and product teams
- Faster developer onboarding

---

*This IDP is actively being evolved as a portfolio project to demonstrate modern Platform Engineering practices (May 2026).*
