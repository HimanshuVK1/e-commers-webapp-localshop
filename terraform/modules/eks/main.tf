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

      # Explicitly provide the node role ARN created in the IAM module
      node_role_arn = var.eks_node_group_role_arn
      instance_profile_arns = [var.eks_node_group_instance_profile_arn]
      # Letting the module manage the launch template ensures correct security group attachments
      create_launch_template = true
      
      # Ensure nodes have necessary tags for discovery
      tags = {
        "kubernetes.io/cluster/${var.project_name}-${var.environment}-cluster" = "owned"
      }
    }
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }

  access_entries = {
    console_user = {
      principal_arn     = "arn:aws:iam::970547369309:user/himanshu1vadmin"
      kubernetes_groups = ["system:masters"]
    }
    github_actions_role = {
      principal_arn     = "arn:aws:iam::970547369309:role/localshop-dev-github-actions-role"
      kubernetes_groups = ["system:masters"] # Use system:masters for deployment role
    }
    # Nodes need to be authorized in Access Entries when using API_AND_CONFIG_MAP or API modes
    node_role = {
      principal_arn = var.eks_node_group_role_arn
      type          = "EC2_LINUX"
    }
  }

}

resource "aws_iam_role" "external_secrets_irsa" {
  name_prefix = "localshop-${var.environment}-external-secrets-irsa-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${module.eks.oidc_provider_extract_from_arn}:sub" = "system:serviceaccount:external-secrets:external-secrets"
          }
        }
      },
    ]
  })

  tags = {
    Name        = "external-secrets-irsa-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "external_secrets_irsa_policy" {
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite" # Example policy
  role       = aws_iam_role.external_secrets_irsa.name
}