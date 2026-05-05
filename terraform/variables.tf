variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "localshop"
}

variable "github_repo" {
  description = "GitHub repository (format: owner/repo)"
  type        = string
  default     = "HimanshuVK1/e-commers-webapp-localshop"
}

variable "db_password" {
  description = "Password for the RDS master user"
  type        = string
  sensitive   = true
  default     = "SuperSecret123!" # Override via TF_VAR_db_password
}


