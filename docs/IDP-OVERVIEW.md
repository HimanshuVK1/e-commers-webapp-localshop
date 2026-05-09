# Internal Developer Platform (IDP) – LocalShop Platform Layer

**Status:** Active Development | **Branch:** `feature/idp-enhancements`

## Overview

This repository contains the **foundational layers of an Internal Developer Platform (IDP)** for microservices workloads. The goal is to provide developers with self-service, secure, and standardized ways to provision infrastructure, deploy applications, and manage operations — without needing deep cloud or Kubernetes expertise.

We treat infrastructure and delivery as a **product** for internal engineering teams.

## Core Platform Capabilities

| Capability                    | Technology                          | Self-Service Level | Description |
|-------------------------------|-------------------------------------|--------------------|-------------|
| **Infrastructure Provisioning** | Terraform + Crossplane (planned)   | High               | Modular, reusable Terraform modules for EKS, RDS, VPC, and networking using `terraform-aws-modules` |
| **Application Delivery**        | ArgoCD + Helm + GitOps             | Very High          | Declarative, automated deployments with image updater and rollback |
| **Secrets Management**          | External Secrets Operator + AWS Secrets Manager + IRSA | High | Zero-trust dynamic secret injection |
| **Security & Compliance**       | Checkov + Kyverno (planned) + Policy-as-Code | High | Automated scanning and guardrails enforced at deployment time |
| **AI-Augmented Operations**     | Gemini CLI + Amazon EKS MCP + GitHub MCP | High | Agentic DevOps – autonomous infrastructure management, policy enforcement, and GitHub operations |
| **Developer Portal**            | Planned (Backstage)                | Medium             | Future self-service catalog and golden path templates |

## Golden Paths

Developers can follow well-defined, opinionated workflows:

- **New Microservice Onboarding** → See [Golden Paths](./GOLDEN-PATHS.md)
- **Self-Service Database Provisioning** (RDS via Terraform)
- **GPU Workload Deployment** (NVIDIA A100/T4 support)

## Architecture

```
Developer (Self-Service)
        ↓
Backstage / Golden Path Templates (Planned)
        ↓
Terraform Modules (EKS, RDS, Networking)
        ↓
ArgoCD GitOps + Helm Charts
        ↓
EKS Cluster + External Secrets + Policies
        ↓
Production Workloads
```

## Key Benefits

- **Reduced Cognitive Load**: Developers no longer write raw Kubernetes YAML or Terraform from scratch
- **Faster Time-to-Prod**: Environment provisioning time reduced from hours to minutes
- **Security by Default**: All workloads pass automated policy checks
- **AI-Powered Operations**: Agents handle routine tasks and compliance

## Current Status (May 2026)

- ✅ Modular Terraform platform modules (EKS + RDS + VPC)
- ✅ GitOps delivery with ArgoCD
- ✅ Secure secrets abstraction layer
- ✅ AI Agent integration (Gemini + EKS MCP + GitHub MCP)
- ✅ Automated security scanning (Checkov)
- ⏳ Backstage developer portal (in planning)
- ⏳ Crossplane control plane (in planning)

## How to Use

1. Clone the repo
2. Follow the golden path in `docs/GOLDEN-PATHS.md`
3. Raise a PR → ArgoCD automatically deploys

---

*This platform is being built as part of transitioning from traditional DevOps to Platform Engineering.*