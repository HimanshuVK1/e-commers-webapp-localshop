data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# 1. KMS Keys Module
module "kms" {
  source = "./modules/kms"

  project_name = var.project_name
  environment  = var.environment
  account_id   = local.account_id
}

# 2. Logging Module (S3 Access Logs)
module "logging" {
  source = "./modules/logging"

  project_name            = var.project_name
  environment             = var.environment
  account_id              = local.account_id
  kms_key_arn             = module.kms.logs_key_arn
  s3_access_log_bucket_id = "temp-value" # Dummy value, will fix later.
}

# 3. VPC Module
module "vpc" {
  source = "./modules/vpc"

  environment             = var.environment
  project_name            = var.project_name
  kms_key_arn             = module.kms.logs_key_arn
  s3_access_log_bucket_id = module.logging.bucket_id
}

# 4. Security Module (CloudTrail)
module "security" {
  source = "./modules/security"

  project_name            = var.project_name
  environment             = var.environment
  account_id              = local.account_id
  kms_logs_key_arn        = module.kms.logs_key_arn
  kms_cloudtrail_key_arn  = module.kms.cloudtrail_key_arn
  s3_access_log_bucket_id = module.logging.bucket_id
}

# 5. IAM Module (GitHub Actions OIDC)
module "iam" {
  source = "./modules/iam"

  environment = var.environment
  github_repo = var.github_repo
}

# 6. ECR Module
module "ecr" {
  source = "./modules/ecr"

  project_name = var.project_name
  environment  = var.environment
}

# 7. EKS Module
module "eks" {
  source = "./modules/eks"

  project_name                        = var.project_name
  environment                         = var.environment
  vpc_id                              = module.vpc.vpc_id
  private_subnets                     = module.vpc.private_subnets
  eks_node_group_role_arn             = module.iam.eks_node_group_role_arn
  eks_node_group_instance_profile_arn = module.iam.eks_node_group_instance_profile_arn
}

# 8. RDS Module (PostgreSQL)
module "rds" {
  source = "./modules/rds"

  project_name     = var.project_name
  environment      = var.environment
  vpc_id           = module.vpc.vpc_id
  database_subnets = module.vpc.database_subnets
}

# --- EKS Authentication & Helm Provider ---

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

# 9. ArgoCD Bootstrap Module
module "argocd" {
  source = "./modules/argocd"

  github_repo = var.github_repo

  depends_on = [module.eks]
}
