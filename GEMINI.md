# GEMINI.md - Instructional Context for LocalShop

## 1. Project Overview
**LocalShop** is a production-grade e-commerce microservices application. It is architected for cloud-native deployment on **AWS** using **Terraform** for infrastructure and **GitOps (ArgoCD)** for continuous delivery.

- **Frontend:** Next.js 14 (App Router), Tailwind CSS, shadcn/ui, Zustand.
- **Backend:** Node.js (Express) Microservices.
- **Messaging:** RabbitMQ (Event-driven inventory and notifications).
- **Databases:** PostgreSQL (Relational), MongoDB (Document), Redis (Caching).
- **Orchestration:** Amazon EKS (Kubernetes).
- **Security:** Distroless images, Multi-stage builds, non-root users, AWS Secrets Manager.

## 2. Infrastructure & Services

| Service | Port | Database/Infra | Frameworks | Description |
| :--- | :--- | :--- | :--- | :--- |
| **Gateway** | 8000 | - | Express, http-proxy-middleware | Central entry point, JWT auth, proxying. |
| **Frontend** | 3000 | - | Next.js 14, Tailwind, shadcn/ui | Next.js client interface. |
| **User Service** | 8001 | PostgreSQL | Express, Sequelize | Auth, registration, and profile management. |
| **Product Service** | 8002 | MongoDB | Express, Mongoose | Product catalog management and seeding. |
| **Cart Service** | 8003 | Redis | Express, redis | Fast temporary storage for user carts. |
| **Order Service** | 8004 | PostgreSQL | Express, Sequelize, amqplib | Order processing and event orchestration. |
| **Inventory Service** | 8006 | MongoDB | Express, Mongoose, amqplib | Real-time stock management. |
| **Payment Service** | 8005 | - | Express, amqplib | Simulated payment processing. |
| **Notification Service** | 8007 | - | Node.js, amqplib | Simulated email/SMS notifications. |
Applied fuzzy match at line 14-25.
## 3. DevOps & CI/CD Workflow

The project utilizes **GitHub Actions** for automated CI/CD and **ArgoCD** for GitOps-based deployment to EKS.

### Service CI/CD Pipeline
Every push to the `main` branch triggers a multi-stage pipeline:
1.  **Code Analysis:** Static code analysis and security scanning via **SonarQube**.
2.  **Vulnerability Scan:** Dependency and filesystem scanning using **Trivy**.
3.  **Build:** Multi-stage Docker build using optimized **Distroless** base images.
4.  **Image Scan:** Container image vulnerability scanning with **Trivy**.
5.  **Publish:** Pushing verified images to **Docker Hub**.
6.  **Deploy:** ArgoCD detects changes in the GitOps repository and synchronizes the EKS cluster.
7.  **Verify:** Automated **Integration Testing** runs against the EKS environment.

### Infrastructure as Code (Terraform)
Infrastructure is managed via a dedicated CI/CD pipeline that provisions:
- **Networking:** VPC with public/private subnets, NAT Gateways, and Security Groups.
- **Compute:** Amazon EKS Cluster with managed Node Groups and auxiliary EC2 VMs.
- **Delivery:** Amazon CloudFront with Application Load Balancers (ALB).
- **Secrets:** Integration with **AWS Secrets Manager** for secure environment variable injection.
- **Storage:** S3 Buckets for logging and monitoring data persistence.

### EKS Platform Setup
The EKS cluster is pre-configured with essential platform services:
- **Ingress:** Nginx Ingress Controller for traffic routing.
- **GitOps:** ArgoCD for automated application lifecycle management.
- **Observability:** 
    - **Prometheus & Grafana:** For metrics collection and visualization.
    - **Loki:** For log aggregation (integrated with **AWS S3** for long-term storage).
    - **Metrics Server:** For HPA (Horizontal Pod Autoscaler) support.
- **Compliance:** Security compliance ready with automated audit logging and IAM OIDC providers for fine-grained permissions.

## 4. Local Development

### Commands
- **Full Start:** `docker-compose up -d --build`
- **Shutdown:** `docker-compose down`
- **Restart a Service:** `docker-compose restart <service-name>`
- **Re-seed Products:** `docker-compose restart product-service`

### Manual Setup
1.  Install dependencies: `npm install` in root and service folders.
2.  Set up environment variables using `.env.example` as a template.
3.  Start infrastructure via `docker-compose-infra.yml`.

## 5. Development Conventions

### Coding Style
- **Frontend:** TypeScript (`.tsx`), `lucide-react` icons, `shadcn/ui` components.
- **API Responses:** 
  - Success: `{ "success": true, "data": { ... } }`
  - Error: `{ "success": false, "error": "message" }`

### Security Best Practices
- **Images:** Must use **Distroless** base images and multi-stage builds.
- **User:** All containers run as a **non-root user** (UID 65532).
- **Secrets:** Never commit `.env` files. Use **AWS Secrets Manager** in production.

## 6. Architectural Principles
- **Event-Driven:** Async communication via **RabbitMQ Fanout Exchange** (`order_events`).
- **Statelessness:** Microservices are stateless; persistence is delegated to relational/document databases.
- **GitOps:** The Git repository is the single source of truth for both application and infrastructure state.
