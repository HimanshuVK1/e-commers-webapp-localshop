output "logs_key_arn" {
  description = "The ARN of the KMS key for logs"
  value       = module.logs_key.key_arn
}

output "logs_key_id" {
  description = "The ID of the KMS key for logs"
  value       = module.logs_key.key_id
}

output "cloudtrail_key_arn" {
  description = "The ARN of the KMS key for cloudtrail"
  value       = module.cloudtrail_key.key_arn
}

output "cloudtrail_key_id" {
  description = "The ID of the KMS key for cloudtrail"
  value       = module.cloudtrail_key.key_id
}
