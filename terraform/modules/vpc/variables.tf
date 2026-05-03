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
