# 🚀 LocalShop Internal Developer Platform (IDP)

**A production-grade demonstration of modern Platform Engineering practices.**

This repository showcases a complete **Internal Developer Platform (IDP)** foundation built to empower developers with self-service capabilities, golden paths, GitOps, and secure infrastructure on AWS EKS.

---

## 🌟 What is an Internal Developer Platform?

An IDP is a **self-service layer** built by the platform team that allows developers to:
- Provision environments and infrastructure without tickets
- Deploy applications using standardized, secure workflows (Golden Paths)
- Get consistent security, observability, and compliance by default

The goal is to **reduce cognitive load** and accelerate developer velocity while maintaining enterprise-grade standards.

---

## ✨ Platform Capabilities

- **Self-Service Infrastructure** — Reusable Terraform modules for EKS, RDS, VPC
- **Golden Path Deployments** — Backstage templates + Helm + ArgoCD GitOps
- **Secure Secrets Management** — External Secrets Operator + AWS Secrets Manager + IRSA
- **Policy-as-Code & Guardrails** — Checkov + Kyverno ready
- **Developer Portal** — Backstage with software templates
- **AI-Augmented Operations** — GitHub MCP + Gemini CLI integration

---

## 🏗 Project Structure

```bash
.
├── backstage/          # Developer Portal + Self-Service Templates
├── platform/           # Policies, guardrails & platform logic
├── terraform/          # Reusable Infrastructure as Code
├── argocd/             # GitOps manifests
├── helm/               # Application packaging
├── examples/           # Demo applications (LocalShop)
├── docs/               # Comprehensive documentation
└── .github/            # CI/CD workflows
```

---

## 🛠 Tech Stack

**Platform Core**
- Backstage
- Terraform
- ArgoCD + Helm
- External Secrets Operator

**Security & Compliance**
- Kyverno, Checkov
- IRSA, RBAC, least privilege

**Observability & Operations**
- Prometheus / Grafana ready
- AI agents (Gemini + MCP)

---

## 📋 Golden Paths

See [docs/GOLDEN-PATHS.md](docs/GOLDEN-PATHS.md) for self-service workflows.

## 📚 Documentation

- [IDP Overview](docs/IDP-OVERVIEW.md)
- [Golden Paths Guide](docs/GOLDEN-PATHS.md)

---

## 🎯 Purpose

This project demonstrates real-world **Platform Engineering** skills and serves as a strong portfolio piece for **Platform Engineer**, **SRE**, and **DevOps** roles.

Built as part of transitioning from traditional DevOps/SRE to full Platform Engineering.

---

**Made with ❤️ for better Developer Experience**

