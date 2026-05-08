variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "environment" {
  description = "The environment (e.g. dev, prod)"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where the RDS instance will be deployed"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block of the VPC for security group ingress"
  type        = string
}

variable "database_subnet_group_name" {
  description = "The name of the database subnet group"
  type        = string
}
