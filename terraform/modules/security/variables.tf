variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "environment" {
  description = "The environment name (e.g., dev, prod)"
  type        = string
}

variable "account_id" {
  description = "The AWS account ID"
  type        = string
}

variable "logging_bucket_id" {
  description = "The ID of the S3 bucket to use for access logging"
  type        = string
}

variable "kms_key_arn" {
  description = "The ARN of the KMS key to use for SNS encryption (optional)"
  type        = string
  default     = null
}
