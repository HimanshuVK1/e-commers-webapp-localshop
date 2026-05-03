# LocalShop | Premium E-Commerce Microservices

<img src="frontend/public/logo.svg" width="120" alt="LocalShop Logo" />

LocalShop is a production-grade, fully functional e-commerce platform built with a microservices architecture. It is designed for cloud-native scalability while maintaining a seamless local development experience.

## 🚀 Key Features

- **Clean Separation:** Isolated application code (`webapp/`) and infrastructure as code (`terraform/`).
- **Scalable Microservices:** 8 independent services (including FastAPI) + API Gateway.
- **Modern UI/UX:** Built with Next.js 14, Tailwind CSS, and `shadcn/ui`.
- **Event-Driven:** Real-time inventory and notification updates via RabbitMQ.
- **Production-Ready Docker:** Multi-stage builds, Distroless images, and non-root users.

---

## 🏗 Repository Structure

```text
.
├── .agents/          # Interoperable AI agent skills
├── terraform/        # Modular AWS Infrastructure (VPC, EKS, RDS)
└── webapp/           # Application Source Code & Docker Orchestration
    ├── frontend/     # Next.js 14 Dashboard
    ├── gateway/      # API Gateway (Express)
    └── services/     # Microservices (Node.js & FastAPI)
```

---

## 🛠 Tech Stack & Frameworks

### Frontend
- **Next.js 14 (App Router):** Core React framework.
- **Tailwind CSS & shadcn/ui:** Styling and professional components.
- **Zustand:** Lightweight state management.

### Backend Microservices
- **Express.js (Node.js):** Core framework for Gateway and Node services.
- **FastAPI (Python):** Used for high-performance **Analytics**.
- **Sequelize & Mongoose:** ORM/ODM for PostgreSQL and MongoDB.
- **amqplib:** RabbitMQ messaging client.

---

## 🛡 Security & Best Practices

- **Distroless Runtime:** Minimal attack surface with shell-free images.
- **Non-Root Execution:** All containers run as restricted user (UID 65532).
- **Native S3 Locking:** Modern, DynamoDB-free Terraform state management.
- **Strict Versioning:** All CLI and provider versions are strictly pinned.

---

## 🛠 Getting Started

### Prerequisites
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Terraform 1.15.1+](https://www.terraform.io/)

### Installation
1.  **Clone the repository:**
    ```bash
    git clone https://github.com/HimanshuVK1/e-commers-webapp-localshop.git
    cd e-commers-webapp-localshop
    ```

2.  **Start the Webapp:**
    ```bash
    cd webapp
    # Copy all .env.example files to .env in each sub-directory
    docker-compose up -d --build
    ```

---

### Developer Context
This project utilizes an **`AGENTS.md`** file to provide durable instructional context for AI agents. Refer to this file for technical standards, check gates, and architecture rules.

## 📜 License
This project uses high-quality images from Unsplash under the [Unsplash License](https://unsplash.com/license).
