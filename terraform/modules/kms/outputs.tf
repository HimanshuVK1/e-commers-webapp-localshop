output "logs_key_arn" {
  description = "The ARN of the logs KMS key"
  value       = module.kms_logs.key_arn
}

output "cloudtrail_key_arn" {
  description = "The ARN of the cloudtrail KMS key"
  value       = module.kms_cloudtrail.key_arn
}
