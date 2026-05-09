# 🚀 LocalShop Internal Developer Platform (IDP)

**A production-grade Internal Developer Platform (IDP) built to demonstrate modern Platform Engineering practices.**

This project showcases how to build **self-service golden paths** for developers using best-in-class tools — enabling fast, secure, and compliant microservices delivery on AWS EKS.

---

## 🌟 What is This Platform?

An **Internal Developer Platform** that allows developers to:
- Provision compliant environments quickly
- Deploy microservices using standardized golden paths
- Manage infrastructure and applications with GitOps
- Have security and compliance enforced automatically

Instead of managing raw Terraform, Kubernetes manifests, or tickets — developers get **self-service capabilities** through Backstage templates and GitOps workflows.

---

## ✨ Key Platform Capabilities

- **Self-Service Infrastructure Provisioning** – Modular Terraform for EKS, RDS, VPC
- **Golden Path Deployments** – Backstage Software Templates + Helm + ArgoCD
- **GitOps Continuous Delivery** – ArgoCD with Image Updater
- **Secure Secrets Management** – External Secrets Operator + AWS Secrets Manager + IRSA
- **Policy-as-Code** – Security & compliance guardrails (Checkov + Kyverno ready)
- **Developer Portal** – Backstage with software templates
- **Observability & Reliability** foundations

---

## 🏗 Project Structure

```bash
.
├── backstage/          # Developer Portal + Golden Path Templates
├── platform/           # Core platform components & policies
├── terraform/          # Reusable IaC modules (EKS, RDS, VPC)
├── argocd/             # GitOps manifests
├── helm/               # Application Helm charts
├── examples/           # Demo application (LocalShop e-commerce)
├── docs/               # Documentation
└── .github/workflows/  # CI/CD pipelines
```

---

## 🛠 Tech Stack

**Core Platform Tools**
- **Backstage** – Developer Portal & Self-Service Templates
- **Terraform** – Infrastructure as Code
- **ArgoCD** – GitOps Continuous Delivery
- **Helm** – Application packaging
- **External Secrets Operator** – Secrets management
- **AWS EKS** – Kubernetes runtime

**Security & Compliance**
- Kyverno (Policy-as-Code)
- Checkov (IaC scanning)
- IRSA, RBAC, least-privilege

---

## 📋 Golden Paths (Self-Service Workflows)

1. **New Microservice** → Use the [Backstage Template](backstage/templates/new-microservice) to scaffold a new service with Helm chart, ArgoCD config, and best practices.
2. **Infrastructure Provisioning** → Reusable Terraform modules for EKS clusters and databases.
3. **Secure Deployment** → GitOps + automated policy enforcement.

---

## 📚 Documentation

- [IDP Overview](docs/IDP-OVERVIEW.md)
- [Golden Paths Guide](docs/GOLDEN-PATHS.md)
- [Backstage Templates](backstage/templates/)

---

## 🎯 Purpose of This Repository

This project serves as a **portfolio demonstration** of real-world Platform Engineering skills, including:
- Building Internal Developer Platforms
- Creating Golden Paths & Self-Service experiences
- Implementing GitOps at scale
- Infrastructure as Code best practices
- Secure & observable platform design

Perfect example for **Platform Engineer**, **SRE**, and **DevOps** roles.

---

## 📄 License

This project is open for educational and demonstration purposes.

---

**Built with ❤️ for Platform Engineering**

Want to see it in action? Check the `backstage/templates` folder and documentation.