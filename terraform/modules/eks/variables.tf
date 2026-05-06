variable "project_name" { type = string }
variable "environment" { type = string }
variable "vpc_id" { type = string }
variable "private_subnets" { type = list(string) }
variable "eks_node_group_role_arn" {
  description = "ARN of the IAM role for EKS node groups"
  type        = string
}

variable "eks_node_group_instance_profile_arn" {
  description = "ARN of the IAM instance profile for EKS node groups"
  type        = string
}
