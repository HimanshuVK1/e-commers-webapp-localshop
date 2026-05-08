variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "environment" {
  description = "The deployment environment (e.g., dev, prod)"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the cluster will be deployed"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block of the VPC"
  type        = string
}

variable "private_subnets" {
  description = "A list of private subnet IDs for the EKS cluster and nodes"
  type        = list(string)
}

variable "admin_user_arn" {
  description = "The IAM ARN of the admin user for EKS console access"
  type        = string
}

variable "github_actions_role_arn" {
  description = "The IAM ARN of the role for GitHub Actions CI/CD"
  type        = string
}
