# 🚀 LocalShop Internal Developer Platform (IDP)

**This is not just an e-commerce application.**  
It is a **production-grade Internal Developer Platform** with AI-augmented operations.

> **Goal**: Enable developers to ship microservices to AWS EKS in minutes with security, observability, and compliance built-in — using golden paths and self-service tooling.

---

## 🎯 Platform Engineering Highlights

- **Reusable Infrastructure Modules** (Terraform)
- **GitOps Self-Service Delivery** (ArgoCD + Helm)
- **Secure Secrets Abstraction** (External Secrets Operator + AWS Secrets Manager)
- **Policy-as-Code & Compliance** (Checkov + planned Kyverno)
- **AI Agent Layer** (Gemini CLI + EKS MCP + **GitHub MCP**)
- **Golden Paths** for common developer workflows

**New to this branch (`feature/idp-enhancements`)**: Comprehensive IDP documentation + Golden Paths

---

# LocalShop E-Commerce System

<img src="webapp/frontend/public/logo.svg" width="120" alt="LocalShop Logo" />

A production-grade, microservices-based e-commerce platform with integrated **Agentic DevOps**.

## 🏗 Project Architecture

This repository is divided into three core pillars:

1.  **Infrastructure (`/terraform`)**: Modular AWS Infrastructure as Code using `terraform-aws-modules`. Features 3-tier networking, EKS (Spot Instances), Single-AZ RDS, and automated ArgoCD bootstrapping. Configured for **Agentic DevOps** using the Amazon EKS MCP Server.
2.  **Application (`/webapp` & `/helm`)**: A distributed microservices system consisting of 8 services (Node.js/FastAPI), a Next.js 14 frontend, and RabbitMQ messaging, packaged via custom Helm charts.
3.  **GitOps (`/platform` & `/argocd`)**: Automated CD via ArgoCD and ArgoCD Image Updater, monitoring ECR registries for new builds.

---

## 🤖 Agentic DevOps Workspace

This project uses the **Gemini CLI** to power an autonomous DevOps team. Our specialized subagents are configured to maintain project standards and security.

### EKS MCP Server Integration
The infrastructure is primed for the **Amazon EKS Model Context Protocol (MCP) Server**. This allows AI coding assistants to securely interface with the EKS API and CloudWatch logs for autonomous cluster troubleshooting and resource management using natural language.

- **`@tf-writer`**: Senior Terraform Engineer. Generates standardized, modular IaC with integrated MCP tools.
- **`@security-auditor`**: AWS Security Specialist. Performs proactive audits and maintains a "Secure by Design" posture using Checkov and dynamic VPC hardening.
- **`@cost-optimizer`**: Cloud Cost Specialist. Manages NAT Gateway and Endpoint costs, currently optimized for ~$103/mo in ap-south-1.

### Security Posture (Verified):
- ✅ **CloudTrail & VPC Flow Logs** (Audit Traceability)
- ✅ **SSE-KMS Encryption** (Data Protection)
- ✅ **VPC Interface Endpoints** (Network Isolation)
- ✅ **S3 Versioning & Lifecycles** (Data Integrity)
- ✅ **External Secrets Operator** (Dynamic Secrets Injection via AWS Secrets Manager)

### Key Skills:
- `tf-plan`: Automated risk assessment and plan analysis.
- `tf-apply`: Safe execution with post-deployment verification (CloudFront/S3).
- `scaffold-terraform`: Enforces architectural standards for new AWS resources.

---

## 🛡 Technical Mandates

All development and operations must adhere to the foundational mandates defined in **`GEMINI.md`**. This includes:
- **Security:** Distroless images, non-root users, and private S3 buckets.
- **Standards:** Modular Terraform organization and pinned provider versions.

---

## 🚀 Getting Started

### 1. Infrastructure Setup
See [terraform/README.md](terraform/README.md) (or consult `@tf-writer`) for instructions on deploying the AWS environment.

### 2. Application Setup
See [webapp/README.md](webapp/README.md) for local development instructions using Docker Compose.

### 3. Agentic Workflow
Ensure you have the Gemini CLI installed and run the following to activate the workspace agents:
```bash
/skills reload
/agents reload
```
For detailed instructions on leveraging the EKS and GitHub MCP servers, refer to the [Agentic DevOps Guide](ai_assistant.md).
For a comprehensive breakdown of the deployment pipeline, refer to the [CI/CD & GitOps Flow](cicdflow.md).

## 📄 Platform Documentation (New)

- [IDP Overview](docs/IDP-OVERVIEW.md) — Full platform vision and capabilities
- [Golden Paths](docs/GOLDEN-PATHS.md) — Standardized developer workflows

## 📄 License

This project is for educational and prototype purposes. Application images used are under the Unsplash License.