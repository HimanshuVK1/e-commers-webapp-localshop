variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "localshop"
}

variable "kms_key_arn" {
  description = "KMS key ARN for S3 encryption"
  type        = string
}

variable "s3_access_log_bucket_id" {
  description = "The ID of the S3 bucket for access logging"
  type        = string
}
