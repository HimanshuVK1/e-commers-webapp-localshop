output "repository_urls" {
  description = "Map of ECR repository URLs indexed by service name"
  value       = { for k, v in module.ecr : k => v.repository_url }
}

output "repository_arns" {
  description = "Map of ECR repository ARNs indexed by service name"
  value       = { for k, v in module.ecr : k => v.repository_arn }
}

output "repository_registry_ids" {
  description = "Map of ECR repository registry IDs indexed by service name"
  value       = { for k, v in module.ecr : k => v.repository_registry_id }
}
