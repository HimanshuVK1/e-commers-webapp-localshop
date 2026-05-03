# VPC 3-Tier Architecture Specification

Every VPC created for LocalShop must follow this 3-tier design for maximum security and network isolation.

## Subnet Tiers

1.  **Public Subnets:**
    - **Purpose:** External-facing resources (ALB, NAT Gateways).
    - **Connectivity:** Direct route to Internet Gateway (IGW).
    - **Usage:** Load Balancers and Bastion Hosts only.

2.  **Private Subnets:**
    - **Purpose:** Application layer (EKS Nodes, EC2 instances).
    - **Connectivity:** Route to Internet via NAT Gateway (located in Public Subnet).
    - **Usage:** Microservices, EKS pods, internal application logic.

3.  **Isolated Subnets:**
    - **Purpose:** Data layer (RDS, MongoDB, Redis).
    - **Connectivity:** **NO** internet access (No IGW, No NAT).
    - **Usage:** Databases and sensitive stateful storage.

## Best Practices
- **Multi-AZ:** Subnets must be distributed across at least 3 Availability Zones (e.g., `ap-south-1a`, `ap-south-1b`, `ap-south-1c`).
- **Tagging:** Use standard Kubernetes tags if the VPC is intended for EKS:
    - `kubernetes.io/role/elb = 1` (Public)
    - `kubernetes.io/role/internal-elb = 1` (Private)
- **Flow Logs:** Enable VPC Flow Logs for audit and security monitoring.
