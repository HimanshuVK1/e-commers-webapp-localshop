# EKS Cluster Architecture Specification

All EKS clusters must follow these security and scalability standards.

## Cluster Configuration
1.  **Endpoint Access:**
    - **Private Access:** MUST be enabled (Control plane to worker node communication).
    - **Public Access:** Should be restricted by CIDR whitelist or disabled entirely in production.
2.  **Authentication:**
    - Use **IAM Roles for Service Accounts (IRSA)** for pod-level AWS permissions.
3.  **Compute:**
    - Use **Managed Node Groups** for easier lifecycle management.
    - Nodes must reside in **Private Subnets**.

## Platform Add-ons (Mandatory)
- **VPC CNI:** Optimized networking.
- **CoreDNS:** Cluster DNS.
- **kube-proxy:** Service networking.
- **AWS Load Balancer Controller:** For ALB/NLB integration.

## Best Practices
- **Encryption:** Enable KMS encryption for Kubernetes secrets.
- **Logging:** Enable control plane logging (API, Audit, Authenticator) to CloudWatch.
- **Version:** Stay within one release of the latest stable EKS version.
