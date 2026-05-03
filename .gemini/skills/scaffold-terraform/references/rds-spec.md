# RDS Database Specification

Standards for relational database deployment and security.

## Configuration
1.  **Network Isolation:**
    - Must reside in **Isolated Subnets** (No internet access).
    - Public Accessibility MUST be set to `false`.
2.  **High Availability:**
    - **Multi-AZ:** Enabled for production environments.
3.  **Storage:**
    - **Encryption:** Storage must be encrypted at rest using AWS KMS.
    - **Performance:** Use `gp3` or `io1` based on workload.

## Security
- **Auth:** Prefer IAM Database Authentication where possible.
- **Backups:** Enable automated backups with a minimum 7-day retention.
- **Monitoring:** Enable Enhanced Monitoring and Performance Insights.

## Connectivity
- Allow ingress ONLY from specific application Security Groups (Private subnets).
