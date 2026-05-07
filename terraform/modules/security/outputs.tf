output "cloudtrail_bucket_id" {
  description = "The ID of the CloudTrail bucket"
  value       = aws_s3_bucket.cloudtrail.id
}

output "cloudtrail_arn" {
  description = "The ARN of the CloudTrail"
  value       = aws_cloudtrail.main.arn
}

output "sns_topic_arn" {
  description = "The ARN of the SNS topic for CloudTrail alarms"
  value       = aws_sns_topic.cloudtrail_alarms.arn
}

output "log_group_arn" {
  description = "The ARN of the CloudWatch log group for CloudTrail"
  value       = aws_cloudwatch_log_group.cloudtrail.arn
}
