variable "project_name" {
  type        = string
  description = "Project name for resource tagging"
}

variable "environment" {
  type        = string
  description = "Environment name (dev/prod)"
}

variable "account_id" {
  type        = string
  description = "AWS Account ID"
}

variable "kms_logs_key_arn" {
  type        = string
  description = "KMS key ARN for log group encryption"
}

variable "kms_cloudtrail_key_arn" {
  type        = string
  description = "KMS key ARN for CloudTrail encryption"
}

variable "s3_access_log_bucket_id" {
  type        = string
  description = "S3 bucket ID for access logging"
}
