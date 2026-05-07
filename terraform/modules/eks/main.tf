terraform {
  required_version = "1.15.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.43.0"
    }
  }
}

module "eks" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-eks.git?ref=2d63f1fe283a9a00b2b9d6befced1cd324bf9217" # v21.20.0

  name               = "${var.project_name}-${var.environment}-cluster"
  kubernetes_version = "1.31"

  vpc_id                   = var.vpc_id
  subnet_ids               = var.private_subnets
  control_plane_subnet_ids = var.private_subnets

  # Authentication & RBAC (Modern Best Practice)
  authentication_mode                      = "API_AND_CONFIG_MAP"
  enable_cluster_creator_admin_permissions = true

  # Security: Control Plane Logging
  enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # Security: KMS Encryption for Secrets
  create_kms_key = true
  encryption_config = {
    resources = ["secrets"]
  }

  /*
  # Cluster Security Group Rules
  cluster_security_group_additional_rules = {
    vpc_https = {
      description = "Allow HTTPS from VPC"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      cidr_blocks = ["10.0.0.0/16"]
    }
  }
  */

  # Access Entries
  access_entries = {
    console_user = {
      principal_arn = var.admin_user_arn
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
    node_role = {
      principal_arn = var.node_role_arn
      type          = "EC2_LINUX"
    }
    github_actions_role = {
      principal_arn = var.github_actions_role_arn
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  eks_managed_node_groups = {
    default = {
      name           = "default"
      instance_types = ["t3.medium", "t3a.medium"]
      capacity_type  = "ON_DEMAND"

      min_size     = 1
      max_size     = 3
      desired_size = 2

      # Explicitly use the provided node role
      create_iam_role = false
      iam_role_arn    = var.node_role_arn
    }
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# --- IRSA Role for External Secrets (Native Resource) ---

resource "aws_iam_role" "external_secrets" {
  name_prefix = "${var.project_name}-${var.environment}-external-secrets-"

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
            "${module.eks.oidc_provider}:sub" = "system:serviceaccount:external-secrets:external-secrets"
          }
        }
      },
    ]
  })

  tags = {
    Name        = "external-secrets-irsa"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_iam_role_policy_attachment" "external_secrets_secrets_manager" {
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
  role       = aws_iam_role.external_secrets.name
}
