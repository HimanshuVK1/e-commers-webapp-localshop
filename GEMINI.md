# AGENTS.md - Technical Instruction Manual for LocalShop

## 1. Interaction Protocol
**MANDATORY:** Before executing any tool or command, you MUST briefly explain what you're about to do in 1-2 simple sentences.
- Use plain language; avoid jargon.
- Explain **WHY**, not just what.
- Proceed with the action only after providing this context.

## 2. Project Overview
**LocalShop** is a production-grade e-commerce microservices application. It is architected for cloud-native deployment on **AWS** using **Terraform** for infrastructure and **GitOps (ArgoCD)** for continuous delivery.

- **Frontend:** Next.js 14 (App Router), Tailwind CSS, shadcn/ui, Zustand.
- **Backend:** Node.js (Express) & FastAPI (Python) Microservices.
- **Security:** Distroless images, Multi-stage builds, non-root users, AWS Secrets Manager.

## 2. Infrastructure & Services

| Service | Port | Database/Infra | Frameworks | Responsibility |
| :--- | :--- | :--- | :--- | :--- |
| **Gateway** | 8000 | - | Express, http-proxy-middleware | Central security (JWT) and routing layer. |
| **Frontend** | 3000 | - | Next.js 14, Tailwind, shadcn/ui | User interface and client-side logic. |
| **User Service** | 8001 | PostgreSQL | Express, Sequelize | User lifecycle (Reg/Login) and profile data. |
| **Product Service** | 8002 | MongoDB | Express, Mongoose | Master product catalog and inventory seeding. |
| **Cart Service** | 8003 | Redis | Express, redis | Volatile storage for active shopping sessions. |
| **Order Service** | 8004 | PostgreSQL | Express, Sequelize, amqplib | Purchase processing and event emission. |
| **Inventory Service** | 8006 | MongoDB | Express, Mongoose, amqplib | Real-time stock counting and event consumption. |
| **Analytics Service** | 8008 | - | FastAPI, Python | Event tracking, behavioral stats, and summaries. |
| **Payment Service** | 8005 | - | Express, amqplib | Payment simulation and success validation. |
| **Notification Service** | 8007 | - | Node.js, amqplib | Email/SMS alerts triggered by order events. |

## 3. DevOps & CI/CD Workflow

### Service CI/CD Pipeline
Every push to the `main` branch triggers a multi-stage pipeline with strict **Check Gates**:
1.  **Code Analysis:** SonarQube (Quality Gate must PASS).
2.  **Code Vulnerability Scan:** Trivy (Zero HIGH or CRITICAL in dependencies).
3.  **Build:** Multi-stage Docker build using optimized **Distroless** base images.
4.  **Image Vulnerability Scan:** Trivy (Zero HIGH or CRITICAL in OS/Runtime).
5.  **Publish:** Verified images to Docker Hub.
6.  **Deploy:** ArgoCD EKS synchronization.

### 4. Infrastructure & Security Mandates
- **Zero-Root Resource Policy:** NO resources (`resource` blocks) are allowed in the root `terraform/main.tf`. The root file must exclusively contain `module` calls, `data` sources, and `locals`.
- **AWS Service-Based Modularity:** Terraform modules MUST be named after the underlying **AWS Service** (e.g., `rds`, `documentdb`, `elasticache`), NOT the application service.
- **Explicit Scaffolding:** NEVER add infrastructure for a new service or AWS component without a direct, explicit instruction from the user.
- **Supply Chain Security:** Exclusively use `terraform-aws-modules/*` community modules. All module sources MUST use a Git URL with an exact commit hash (e.g., `source = "git::https://github.com/...git?ref=<hash>"`) instead of semantic version tags.
- **Standardized File Structure:** EVERY module must consist of at least three files: `main.tf`, `variables.tf`, and `outputs.tf`. NO monolithic `main.tf` files.
- **Security-by-Design (Checkov/CIS):** All infrastructure code must be written assuming strict enterprise security scans (e.g., Checkov, Trivy).
- **Technical Integrity & Versioning:** 
  - **Verification-First Rule:** Before proposing or implementing any architecture (e.g., state locking, networking, IAM), I MUST proactively search for the latest best practices, feature shifts, and deprecations for the specific versions pinned in this project (e.g., Terraform 1.15.1+).
  - **No Legacy Assumptions:** I must not rely on historical "industry standards" (like DynamoDB locking) without first verifying if a more modern, native, or cost-effective alternative exists in the current version.
  - **Version-Specific Docs:** When a module or provider is pinned, I must verify the available arguments by checking the `variables.tf` or specific documentation for that exact version/commit hash.
  - **Stability First:** Prefer native Terraform resources for complex security policies to ensure long-term stability across module updates.

#### Infrastructure Quality Gate (Pre-Implementation Checklist)
1.  [ ] Is the module named after an AWS Service (e.g., `rds`) and not an app service (e.g., `user-service`)?
2.  [ ] Does the module use a verified community source pinned to a strict Git commit hash?
3.  [ ] Is the file structure split into `main.tf`, `variables.tf`, and `outputs.tf`?
4.  [ ] Does the root `main.tf` remain free of `resource` blocks?
5.  [ ] Has the user given an explicit, direct instruction to scaffold this specific component?
6.  [ ] Does the code proactively implement security best practices to pass enterprise static analysis tools (e.g., Checkov)?

## 4. Execution Commands (Relative to Root)

- **Start Webapp:** `cd webapp && docker-compose up -d --build`
- **Stop Webapp:** `cd webapp && docker-compose down`
- **Integration Test:** `docker exec -it webapp-gateway-1 node integration-test.js`
- **Terraform Plan:** `cd terraform && terraform plan`

## 5. Custom Skills
This project utilizes interoperable AI agent skills located in the **`.agents/skills/`** directory.

### scaffold-terraform
- **Purpose:** Automates modular AWS infrastructure creation following `references/` specifications.
- **Workflow:** **STOP-AND-ASK.**

### tf-plan
- **Purpose:** Advanced plan analysis for risks, warnings, and deprecations.
- **Workflow:** **STOP-AND-ASK.**

## 6. Architectural Principles
- **Clean Separation:** Application source lives in `webapp/`; Infrastructure in `terraform/`.
- **Event-Driven:** Async communication via RabbitMQ Fanout Exchange.
- **Statelessness:** All persistent data resides in infrastructure containers.
