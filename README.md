# LocalShop | Premium E-Commerce Microservices

<img src="frontend/public/logo.svg" width="120" alt="LocalShop Logo" />

LocalShop is a production-grade, fully functional e-commerce platform built with a microservices architecture. It is designed to run 100% locally using Docker Desktop while adhering to enterprise security and architectural standards.

## 🚀 Key Features

- **Scalable Microservices:** 7 independent services + API Gateway.
- **Modern UI/UX:** Built with Next.js 14, Tailwind CSS, and `shadcn/ui`.
- **Global Cart:** Modern slide-out sheet accessible from any page.
- **Rich Catalog:** 40 premium products with high-resolution, verified visuals.
- **Event-Driven:** Real-time inventory and notification updates via RabbitMQ.
- **Production-Ready Docker:** Multi-stage builds, Distroless images, and non-root users.

---

## 🏗 Architecture Overview

The system consists of the following components:

### Frontend
- **Next.js (Standalone Mode):** Optimized React framework for high-performance delivery.
- **Zustand:** Lightweight state management for cart and user sessions.

### Gateway & Services
1.  **API Gateway:** Single entry point using `http-proxy-middleware` with JWT authentication.
2.  **User Service:** Handles registration, login, and profile management (PostgreSQL).
3.  **Product Service:** Manages the product catalog and seeding (MongoDB).
4.  **Cart Service:** Fast, volatile storage for user shopping carts (Redis).
5.  **Order Service:** Manages transaction history and orchestrates events (PostgreSQL).
6.  **Inventory Service:** Real-time stock management triggered by order events (MongoDB).
7.  **Payment Service:** Simulated payment processing and verification.
8.  **Notification Service:** Simulated email/SMS alerts for orders and payments.

### Infrastructure
- **PostgreSQL:** Relational data (Users, Orders).
- **MongoDB:** Document-based data (Products, Inventory).
- **Redis:** In-memory caching (Carts).
- **RabbitMQ:** Message broker for asynchronous event-driven communication.

---

## 🛡 Security & Best Practices

- **Distroless Images:** Containers contain *only* the application and its runtime. No shell or extra binaries (minimizes attack surface).
- **Non-Root Execution:** All processes run under UID 65532 (nonroot).
- **Credential Isolation:** Sensitive data is managed via localized `.env` files (ignored by Git).
- **Multi-Stage Builds:** Ensures build-time secrets and source code are not included in final images.
- **API Security:** Centralized JWT verification at the Gateway level.
- **Signal Handling:** Configured with `init: true` for proper process management.

---

## 🛠 Getting Started

### Prerequisites
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (Windows/Mac/Linux)
- [Node.js 20+](https://nodejs.org/) (Optional, for local testing)

### Installation
1.  **Clone the repository:**
    ```bash
    git clone https://github.com/HimanshuVK1/e-commers-webapp-localshop.git
    cd e-commers-webapp-localshop
    ```

2.  **Configure Environment Variables:**
    Copy all `.env.example` files to `.env` in their respective directories:
    ```bash
    cp .env.example .env
    cp gateway/.env.example gateway/.env
    # ... repeat for all services
    ```

3.  **Start the Application:**
    ```bash
    docker-compose up -d --build
    ```

### Accessing the App
- **Frontend:** [http://localhost:3000](http://localhost:3000)
- **API Gateway:** [http://localhost:8000](http://localhost:8000)
- **RabbitMQ Dashboard:** [http://localhost:15672](http://localhost:15672) (guest/guest)

---

## 👨‍💻 Development

### Adding Products
To re-seed or expand the catalog, modify `services/product-service/src/seed.js` and restart the service:
```bash
docker-compose restart product-service
```

### Running Tests
The project includes automated integration tests:
```bash
docker exec -it e-commers-webapp-gateway-1 node integration-test.js
```

---

## 📜 License
This project uses high-quality images from Unsplash under the [Unsplash License](https://unsplash.com/license).
