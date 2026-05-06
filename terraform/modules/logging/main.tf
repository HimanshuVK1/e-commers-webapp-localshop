# --- Centralized S3 Access Logging Bucket ---

module "s3_access_logs" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git?ref=af0286ff37a66c2b79faf360e6e2663744b8e5b5"

  bucket        = "localshop-${var.environment}-access-logs-${var.account_id}"
  force_destroy = true

  # Versioning
  versioning = {
    status = "Enabled"
  }

  # Lifecycle Rules
  lifecycle_rule = [
    {
      id      = "log-lifecycle"
      enabled = true

      transition = [
        {
          days          = 90
          storage_class = "GLACIER_IR"
        }
      ]

      expiration = {
        days = 365
      }
    }
  ]

  # Encryption
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = var.kms_key_arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  # Access Log Delivery Policy
  attach_access_log_delivery_policy          = true
  access_log_delivery_policy_source_accounts = [var.account_id]

  # Security Hardening
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  # Deny Non-SSL Requests
  attach_deny_insecure_transport_policy = true

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}
