# --- IAM OIDC Provider for GitHub ---

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# --- IAM Role for GitHub Actions ---

resource "aws_iam_role" "github_actions" {
  name = "localshop-${var.environment}-github-actions-role"

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
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "github-actions-role"
    Environment = var.environment
  }
}

# --- IAM Policy for GitHub Actions (Admin for Migration) ---

resource "aws_iam_role_policy_attachment" "admin_access" {
  # checkov:skip=CKV_AWS_274: Admin access is required for Terraform CI/CD to provision resources.
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
