data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

# 0. KMS Module (Encryption)
module "kms" {
  source = "./modules/kms"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region
  account_id   = local.account_id
}

# 1. IAM Module (Identity & OIDC)
module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
  environment  = var.environment
  github_repo  = var.github_repo
  kms_key_arns = [
    module.kms.logs_key_arn,
    module.kms.cloudtrail_key_arn
  ]
}

# 2. Logging Module (Storage)
module "logging" {
  source = "./modules/logging"

  project_name = var.project_name
  environment  = var.environment
  account_id   = local.account_id
}

# 3. Security Module (Auditing)
module "security" {
  source = "./modules/security"

  project_name      = var.project_name
  environment       = var.environment
  account_id        = local.account_id
  logging_bucket_id = module.logging.bucket_id
  kms_key_arn       = module.kms.cloudtrail_key_arn
}

# 4. VPC Module (Networking)
module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region
}

# 5. EKS Module (Compute)
module "eks" {
  source = "./modules/eks"

  project_name            = var.project_name
  environment             = var.environment
  vpc_id                  = module.vpc.vpc_id
  vpc_cidr                = module.vpc.vpc_cidr_block
  private_subnets         = module.vpc.private_subnets
  admin_user_arn          = "arn:aws:iam::${local.account_id}:user/himanshu1vadmin"
  github_actions_role_arn = module.iam.github_actions_role_arn
}

# 6. RDS Module (Database)
module "rds" {
  source = "./modules/rds"

  project_name               = var.project_name
  environment                = var.environment
  vpc_id                     = module.vpc.vpc_id
  vpc_cidr                   = module.vpc.vpc_cidr_block
  database_subnet_group_name = module.vpc.database_subnet_group_name
}

# 7. ECR Module (Containers)
module "ecr" {
  source = "./modules/ecr"

  project_name = var.project_name
  environment  = var.environment
}

# --- EKS Authentication & Helm Provider (Late Binding) ---

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

# 8. ArgoCD Bootstrap Module
module "argocd" {
  source = "./modules/argocd"

  github_repo = var.github_repo

  depends_on = [module.eks]
}
