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
