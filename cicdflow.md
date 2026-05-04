# LocalShop End-to-End CI/CD & GitOps Flow

This document outlines the complete, automated path that code takes from a developer's local machine to running as a healthy Pod in the production AWS EKS Cluster.

---

## 🏗 The Architecture at a Glance
- **Source Code Management:** GitHub (`dev` branch)
- **Infrastructure as Code (IaC):** Terraform (via GitHub Actions)
- **Continuous Integration (CI):** GitHub Actions (Matrix Builds)
- **Image Registry:** Amazon Elastic Container Registry (ECR)
- **Continuous Delivery (CD / GitOps):** ArgoCD + ArgoCD Image Updater
- **Orchestration:** Amazon EKS (Kubernetes)

---

## 🔄 The 5-Step Automated Workflow

### Step 1: Developer Push (The Trigger)
1. A developer completes their work on a feature branch (e.g., modifying the `user-service` inside the `webapp/` folder).
2. They open a Pull Request against the **`dev`** branch.
3. Upon approval, the PR is merged into `dev`.
4. **Trigger:** This merge event automatically wakes up the GitHub Actions workflows.

### Step 2: Infrastructure Sync (Terraform CI/CD)
*Workflow: `.github/workflows/terraform.yml`*
1. The GitHub Action authenticates securely with AWS using **OIDC** (no long-lived secrets are stored in GitHub).
2. It runs `terraform init` and pulls the remote state from the secure AWS S3 backend (using Native S3 locking).
3. It runs `terraform apply -auto-approve`.
4. **Outcome:** Any changes made to the AWS infrastructure (e.g., adding a new RDS read replica, modifying security groups, upgrading the EKS version) are applied automatically.

### Step 3: Parallel Image Builds (GitHub Actions)
*Workflow: `.github/workflows/build-and-push.yml`*
1. GitHub Actions detects changes in the `webapp/` directory.
2. Using a **Matrix Strategy**, GitHub spins up 10 independent virtual machines to build all 10 microservices **in parallel**.
3. *Resiliency:* The `fail-fast: false` setting ensures that if the `frontend` build fails, the `user-service` build will continue successfully.
4. Each service is built using its respective Dockerfile.
5. The resulting Docker image is tagged uniquely with the **Git Commit SHA** (e.g., `localshop-user-service:a1b2c3d`).
6. **Outcome:** Immutable, versioned Docker images are pushed directly to their respective private AWS ECR repositories.

### Step 4: The GitOps Handoff (ArgoCD Image Updater)
*Location: Inside the EKS Cluster*
1. The CI pipeline finishes successfully. **Note:** The CI pipeline *does not* touch the Kubernetes cluster and *does not* commit back to the GitHub repository.
2. The **ArgoCD Image Updater**, running continuously inside the EKS cluster, polls the AWS ECR registries every two minutes.
3. It detects that a new image tag (`a1b2c3d`) exists for `localshop-user-service`.
4. **Outcome:** The Image Updater automatically instructs ArgoCD to override the Helm parameter for the image tag to the new SHA.

### Step 5: Cluster Reconciliation (ArgoCD)
*Location: Inside the EKS Cluster*
1. **ArgoCD** is the ultimate source of truth for the cluster state. It constantly monitors both the `platform/` and `helm/` directories in the GitHub repository.
2. Receiving the trigger from the Image Updater (or from a direct commit to a Helm chart in the repo), ArgoCD recognizes that the EKS cluster is "Out of Sync."
3. ArgoCD automatically applies the changes to the cluster via Kubernetes API calls.
4. Kubernetes initiates a **Rolling Update**:
   - It spins up a new Pod with the new image.
   - It waits for the new Pod to report as "Healthy" and "Ready" (via health probes).
   - Once the new Pod is healthy, it terminates the old Pod.
5. **Outcome:** The new code is live for users with zero downtime.

---

## 🛠 Manual Overrides & Bootstrapping

### The "Chicken or the Egg" Scenario (Day 1 Only)
On the very first deployment into a completely blank AWS account, a race condition occurs:
1. GitHub Actions tries to push images to ECR, but the ECR repos don't exist yet.
2. The `build-and-push` workflow will fail.
3. The `terraform` workflow will succeed, creating the EKS cluster and the ECR repos.
4. **Resolution:** Simply click **"Re-run all jobs"** on the failed `build-and-push` workflow. The images will push successfully to the new repos, and ArgoCD will automatically detect them and start the pods.

### Bootstrapping ArgoCD
ArgoCD is installed automatically via the Terraform Helm provider (`terraform/modules/argocd`). Once Terraform applies, ArgoCD is immediately available in the cluster and automatically begins synchronizing the `platform` and `localshop-microservices` applications.

---

## 📊 "Agentic" Cluster Management & Observability
Once the workflow is complete and the cluster is running:
- **Metrics & Logs:** Managed by the LGTM stack (Loki, Grafana). S3 provides cost-effective long-term log retention.
- **Agentic DevOps:** The infrastructure is prepared with IAM Access Entries and full control plane logging to support the **Amazon EKS MCP Server**. This allows AI assistants (configured via `cline_mcp_settings.json`) to securely read cluster telemetry and autonomously diagnose issues using natural language.
