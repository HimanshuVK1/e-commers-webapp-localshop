output "github_actions_role_arn" {
  description = "The ARN of the GitHub Actions CI/CD role"
  value       = aws_iam_role.github_actions.arn
}

output "github_actions_role_name" {
  description = "The name of the GitHub Actions CI/CD role"
  value       = aws_iam_role.github_actions.name
}

output "eks_node_group_role_arn" {
  description = "The ARN of the EKS node group IAM role"
  value       = aws_iam_role.eks_node_group.arn
}

output "eks_node_group_role_name" {
  description = "The name of the EKS node group IAM role"
  value       = aws_iam_role.eks_node_group.name
}

output "eks_node_group_instance_profile_arn" {
  description = "The ARN of the EKS node group IAM instance profile"
  value       = aws_iam_instance_profile.eks_node_group.arn
}

output "eks_node_group_instance_profile_name" {
  description = "The name of the EKS node group IAM instance profile"
  value       = aws_iam_instance_profile.eks_node_group.name
}

output "oidc_provider_arn" {
  description = "The ARN of the GitHub OIDC provider"
  value       = aws_iam_openid_connect_provider.github.arn
}
