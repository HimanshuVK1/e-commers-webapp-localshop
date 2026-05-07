terraform {
  required_version = "1.15.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.43.0"
    }
  }
}

module "logs_key" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-kms.git?ref=407e3db34a65b384c20ef718f55d9ceacb97a846"

  description = "KMS key for CloudWatch Logs"
  aliases     = ["localshop-${var.environment}-logs"]

  key_statements = [
    {
      sid = "AllowCloudWatchLogs"
      actions = [
        "kms:Encrypt*",
        "kms:Decrypt*",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:Describe*"
      ]
      resources = ["*"]
      principals = [
        {
          type        = "Service"
          identifiers = ["logs.${var.aws_region}.amazonaws.com"]
        }
      ]
      condition = [
        {
          test     = "ArnLike"
          variable = "kms:EncryptionContext:aws:logs:arn"
          values   = ["arn:aws:logs:${var.aws_region}:${var.account_id}:*"]
        }
      ]
    }
  ]

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

module "cloudtrail_key" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-kms.git?ref=407e3db34a65b384c20ef718f55d9ceacb97a846"

  description = "KMS key for CloudTrail and SNS"
  aliases     = ["localshop-${var.environment}-cloudtrail"]

  key_statements = [
    {
      sid       = "AllowCloudTrail"
      actions   = ["kms:GenerateDataKey*"]
      resources = ["*"]
      principals = [
        {
          type        = "Service"
          identifiers = ["cloudtrail.amazonaws.com"]
        }
      ]
      condition = [
        {
          test     = "StringLike"
          variable = "kms:EncryptionContext:aws:cloudtrail:arn"
          values   = ["arn:aws:cloudtrail:*:${var.account_id}:trail/*"]
        }
      ]
    },
    {
      sid = "AllowSNS"
      actions = [
        "kms:GenerateDataKey*",
        "kms:Decrypt"
      ]
      resources = ["*"]
      principals = [
        {
          type        = "Service"
          identifiers = ["sns.amazonaws.com"]
        }
      ]
    }
  ]

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}
