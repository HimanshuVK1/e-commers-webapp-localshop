# AGENTS.md - Technical Instruction Manual for LocalShop

## 1. Project Overview
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

### Infrastructure as Code (Terraform)
All infrastructure is located in the **`terraform/`** directory following a modular architecture.
- **Structure:** `terraform/` (Root) and `terraform/modules/` (Child).
- **Tooling:** Use `terraform-aws-modules/*`.
- **Versioning:** Strictly fixed CLI (1.15.1) and Provider versions.

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
