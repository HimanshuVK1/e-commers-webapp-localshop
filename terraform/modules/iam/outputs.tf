output "github_actions_role_arn" {
  description = "ARN of the IAM role for GitHub Actions"
  value       = aws_iam_role.github_actions.arn
}

output "eks_node_group_role_arn" {
  description = "ARN of the IAM role for EKS node groups"
  value       = aws_iam_role.eks_node_group.arn
}

output "eks_node_group_instance_profile_arn" {
  description = "ARN of the IAM instance profile for EKS node groups"
  value       = aws_iam_instance_profile.eks_node_group.arn
}
