terraform {
  required_version = "1.15.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.43.0"
    }
  }
}

# --- CloudTrail S3 Bucket (Native) ---

resource "aws_s3_bucket" "cloudtrail" {
  bucket        = "localshop-${var.environment}-cloudtrail-${var.account_id}"
  force_destroy = true

  # checkov:skip=CKV_AWS_144: Cross-region replication is not required for this prototype.
  # checkov:skip=CKV2_AWS_62: Event notifications are not required for this prototype.
  # checkov:skip=CKV_AWS_18: Access logging is enabled.
  # checkov:skip=CKV_AWS_145: AES256 is used for cost efficiency in this prototype.

  tags = {
    Name        = "localshop-${var.environment}-cloudtrail"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_s3_bucket_versioning" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  rule {
    id     = "log-retention"
    status = "Enabled"

    expiration {
      days = 365
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

resource "aws_s3_bucket_logging" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  target_bucket = var.logging_bucket_id
  target_prefix = "cloudtrail/"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.cloudtrail.arn
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.cloudtrail.arn}/AWSLogs/${var.account_id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# --- CloudTrail Setup ---

resource "aws_cloudwatch_log_group" "cloudtrail" {
  # checkov:skip=CKV_AWS_158: KMS encryption is applied using the provided key.
  name              = "/aws/cloudtrail/localshop-${var.environment}"
  retention_in_days = 365
  kms_key_id        = var.kms_key_arn

  tags = {
    Name        = "/aws/cloudtrail/localshop-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_iam_role" "cloudtrail_cw" {
  name_prefix = "localshop-cloudtrail-cw-"

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
}

resource "aws_iam_role_policy" "cloudtrail_cw" {
  name = "cloudtrail-cw-policy"
  role = aws_iam_role.cloudtrail_cw.id

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

resource "aws_sns_topic" "cloudtrail_alarms" {
  name              = "localshop-${var.environment}-cloudtrail-alarms"
  kms_master_key_id = var.kms_key_arn

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_sns_topic_policy" "cloudtrail_alarms" {
  arn = aws_sns_topic.cloudtrail_alarms.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudTrailPublish"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "sns:Publish"
        Resource  = aws_sns_topic.cloudtrail_alarms.arn
      }
    ]
  })
}

resource "aws_cloudtrail" "main" {
  # checkov:skip=CKV_AWS_35: KMS encryption is applied using the provided key.
  name                          = "localshop-${var.environment}-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  kms_key_id                    = var.kms_key_arn

  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
  cloud_watch_logs_role_arn  = aws_iam_role.cloudtrail_cw.arn
  sns_topic_name             = aws_sns_topic.cloudtrail_alarms.name

  tags = {
    Name        = "localshop-${var.environment}-trail"
    Environment = var.environment
    Project     = var.project_name
  }
}
