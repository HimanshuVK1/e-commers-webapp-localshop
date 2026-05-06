module "eks" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-eks.git?ref=85a1a1a0eccea95ffa3f7ac1c6047901a1f0a6cb"

  name               = "${var.project_name}-${var.environment}-cluster"
  kubernetes_version = "1.31"

  vpc_id                   = var.vpc_id
  subnet_ids               = var.private_subnets
  control_plane_subnet_ids = var.private_subnets

  # Enable OIDC provider for IRSA
  enable_irsa = true

  # Support for AWS EKS MCP Server (Agentic DevOps)
  enable_cluster_creator_admin_permissions = true
  authentication_mode                      = "API_AND_CONFIG_MAP"
  endpoint_public_access                   = true

  # MCP Server requires Control Plane logs for autonomous troubleshooting
  enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  cloudwatch_log_group_retention_in_days = 30

  # Cost Optimized Spot instances
  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.medium", "t3a.medium"]
      capacity_type  = "ON_DEMAND"
      min_size       = 1
      max_size       = 3
      desired_size   = 2
    }
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

module "external_secrets_irsa" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-role-for-service-accounts?ref=1d73bcb359419e1b41872ac5ccaf8808b8f1150e"

  name = "${var.project_name}-${var.environment}-external-secrets"

  attach_external_secrets_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["external-secrets:external-secrets"]
    }
  }
}
