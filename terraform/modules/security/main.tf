# --- CloudTrail S3 Bucket ---

module "cloudtrail_bucket" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git?ref=5b923af1ae46e7d073e2b135c303b7c1e0dc54a6"

  bucket        = "localshop-${var.environment}-cloudtrail-logs-${var.account_id}"
  force_destroy = true

  # Versioning
  versioning = {
    status = "Enabled"
  }

  # Lifecycle Rules
  lifecycle_rule = [
    {
      id      = "trail-lifecycle"
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
        kms_master_key_id = var.kms_logs_key_arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  # Bucket Policy for CloudTrail
  attach_policy = true
  policy        = data.aws_iam_policy_document.cloudtrail_logs_policy.json

  # S3 Access Logging
  logging = {
    target_bucket = var.s3_access_log_bucket_id
    target_prefix = "cloudtrail-logs/"
  }

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

data "aws_iam_policy_document" "cloudtrail_logs_policy" {
  statement {
    sid = "AWSCloudTrailAclCheck"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = ["arn:aws:s3:::localshop-${var.environment}-cloudtrail-logs-${var.account_id}"]
  }

  statement {
    sid = "AWSCloudTrailWrite"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::localshop-${var.environment}-cloudtrail-logs-${var.account_id}/AWSLogs/${var.account_id}/*"]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

# --- CloudTrail Configuration ---

resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/aws/cloudtrail/localshop-${var.environment}-trail"
  retention_in_days = 30 # Cost Optimized: 30 days retention as logs are archived to S3
  kms_key_id        = var.kms_logs_key_arn

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_iam_role" "cloudtrail_cloudwatch" {
  name = "localshop-${var.environment}-cloudtrail-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "cloudtrail_cloudwatch" {
  name = "localshop-${var.environment}-cloudtrail-cloudwatch-policy"
  role = aws_iam_role.cloudtrail_cloudwatch.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
      },
    ]
  })
}

resource "aws_sns_topic" "cloudtrail" {
  name              = "localshop-${var.environment}-cloudtrail-sns"
  kms_master_key_id = var.kms_cloudtrail_key_arn

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_sns_topic_policy" "cloudtrail" {
  arn = aws_sns_topic.cloudtrail.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudTrailSNSPublish"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "sns:Publish"
        Resource  = aws_sns_topic.cloudtrail.arn
      }
    ]
  })
}

resource "aws_cloudtrail" "main" {
  name                          = "localshop-${var.environment}-trail"
  s3_bucket_name                = module.cloudtrail_bucket.s3_bucket_id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  kms_key_id                    = var.kms_cloudtrail_key_arn
  sns_topic_name                = aws_sns_topic.cloudtrail.arn

  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
  cloud_watch_logs_role_arn  = aws_iam_role.cloudtrail_cloudwatch.arn

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}
