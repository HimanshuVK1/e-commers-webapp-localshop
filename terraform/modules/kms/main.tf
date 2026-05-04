# --- Logs KMS Key ---

module "kms_logs" {
  source  = "git::https://github.com/terraform-aws-modules/terraform-aws-kms.git?ref=407e3db34a65b384c20ef718f55d9ceacb97a846"

  description = "KMS key for S3 logs encryption"
  aliases     = ["localshop-${var.environment}-logs"]

  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# --- CloudTrail KMS Key ---

module "kms_cloudtrail" {
  source  = "git::https://github.com/terraform-aws-modules/terraform-aws-kms.git?ref=407e3db34a65b384c20ef718f55d9ceacb97a846"

  description = "KMS key for CloudTrail encryption"
  aliases     = ["localshop-${var.environment}-cloudtrail"]

  deletion_window_in_days = 7
  enable_key_rotation     = true

  # Custom policy for CloudTrail
  key_statements = [
    {
      sid    = "Allow CloudTrail to encrypt logs"
      actions = ["kms:GenerateDataKey*"]
      principals = [
        {
          type        = "Service"
          identifiers = ["cloudtrail.amazonaws.com"]
        }
      ]
      conditions = [
        {
          test     = "StringLike"
          variable = "kms:EncryptionContext:aws:cloudtrail:arn"
          values   = ["arn:aws:cloudtrail:*:${var.account_id}:trail/*"]
        }
      ]
    },
    {
      sid    = "Allow CloudTrail to describe key"
      actions = ["kms:DescribeKey"]
      principals = [
        {
          type        = "Service"
          identifiers = ["cloudtrail.amazonaws.com"]
        }
      ]
    }
  ]

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}
