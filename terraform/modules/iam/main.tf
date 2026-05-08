terraform {
  required_version = "1.15.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.43.0"
    }
  }
}

# --- IAM OIDC Provider for GitHub ---

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c3a331631939a1ae4a625cd4244a4963dabbfa2"]

  tags = merge(var.tags, {
    Name = "github-oidc-provider"
  })
}

# --- GitHub Actions CI/CD Role ---

resource "aws_iam_role" "github_actions" {
  name_prefix = "${var.project_name}-${var.environment}-gha-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_repo}:*"
          }
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-github-actions-role"
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_admin" {
  # checkov:skip=CKV_AWS_274: AdministratorAccess is required for IaC provisioning via GitHub Actions.
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# --- EKS Node Group IAM Role ---

resource "aws_iam_role" "eks_node_group" {
  name_prefix = "localshop-${var.environment}-eks-node-group-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name                                                                   = "eks-node-group-role"
    "kubernetes.io/cluster/${var.project_name}-${var.environment}-cluster" = "owned"
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  role       = aws_iam_role.eks_node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.eks_node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy" "node_kms" {
  name_prefix = "localshop-${var.environment}-node-kms-"
  description = "Allow EKS nodes to use KMS keys for encryption/decryption"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Effect   = "Allow"
        Resource = "*" # Scoped to all keys; in production, this should be narrowed.
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "node_kms" {
  role       = aws_iam_role.eks_node_group.name
  policy_arn = aws_iam_policy.node_kms.arn
}

# --- IAM Instance Profile for EKS Nodes ---

resource "aws_iam_instance_profile" "eks_node_group" {
  name = "${aws_iam_role.eks_node_group.name}-profile"
  role = aws_iam_role.eks_node_group.name

  tags = merge(var.tags, {
    Name = "eks-node-group-instance-profile"
  })
}
