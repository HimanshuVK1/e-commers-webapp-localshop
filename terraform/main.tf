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

  project_name = var.project_name
  environment  = var.environment
  account_id   = local.account_id
  kms_key_arn  = module.kms.logs_key_arn
}

# 3. VPC Module
module "vpc" {
  source = "./modules/vpc"

  environment  = var.environment
  project_name = var.project_name
  kms_key_arn  = module.kms.logs_key_arn
  s3_access_log_bucket_id = module.logging.bucket_id
}

# 4. Security Module (CloudTrail)
module "security" {
  source = "./modules/security"

  project_name           = var.project_name
  environment            = var.environment
  account_id             = local.account_id
  kms_logs_key_arn       = module.kms.logs_key_arn
  kms_cloudtrail_key_arn = module.kms.cloudtrail_key_arn
  s3_access_log_bucket_id = module.logging.bucket_id
}
