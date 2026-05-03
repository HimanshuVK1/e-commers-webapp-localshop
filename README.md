# LocalShop E-Commerce System

A production-grade, microservices-based e-commerce platform with integrated **Agentic DevOps**.

## 🏗 Project Architecture

This repository is divided into three core pillars:

1.  **Infrastructure (`/terraform`)**: Modular AWS Infrastructure as Code using `terraform-aws-modules`. Features 3-tier networking, EKS, and RDS isolation.
2.  **Application (`/webapp`)**: A distributed microservices system consisting of 8 services (Node.js/FastAPI), a Next.js 14 frontend, and RabbitMQ messaging.
3.  **Operations (`/.gemini`)**: An autonomous DevOps workspace containing specialized AI Skills and Subagents.

---

## 🤖 Agentic DevOps Workspace

This project uses the **Gemini CLI** to power an autonomous DevOps team. Our specialized subagents are configured to maintain project standards and security:

- **`@tf-writer`**: Senior Terraform Engineer. Generates standardized, modular IaC with integrated MCP tools.
- **`@security-auditor`**: AWS Security Specialist. Performs proactive audits against a strict 9-point security checklist.
- **`@cost-optimizer`**: Cloud Cost Specialist. Analyzes infrastructure for savings and efficiency.

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

## 📜 License
This project is for educational and prototype purposes. Application images used are under the Unsplash License.
