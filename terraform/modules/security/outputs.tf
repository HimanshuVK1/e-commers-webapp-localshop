output "cloudtrail_bucket_id" {
  description = "The ID of the CloudTrail bucket"
  value       = module.cloudtrail_bucket_native.s3_bucket_id
}

output "cloudtrail_arn" {
  description = "The ARN of the CloudTrail"
  value       = aws_cloudtrail.main.arn
}
