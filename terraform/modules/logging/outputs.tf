output "bucket_id" {
  description = "The name of the logging bucket"
  value       = module.s3_access_logs.s3_bucket_id
}

output "bucket_arn" {
  description = "The ARN of the logging bucket"
  value       = module.s3_access_logs.s3_bucket_arn
}
