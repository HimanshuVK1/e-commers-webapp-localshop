module "cloudtrail_bucket_native" {
  source = "./s3_native"

  project_name            = var.project_name
  environment             = var.environment
  account_id              = var.account_id
  kms_key_arn             = var.kms_cloudtrail_key_arn
  kms_logs_key_arn        = var.kms_cloudtrail_key_arn
  s3_access_log_bucket_id = var.s3_access_log_bucket_id
}

# --- CloudTrail Configuration ---

resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/aws/cloudtrail/localshop-${var.environment}-trail"
  retention_in_days = 365 # Ensure retention is at least 365 days
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
  s3_bucket_name                = module.cloudtrail_bucket_native.s3_bucket_id
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
