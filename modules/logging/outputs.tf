output "flow_logs_bucket_name" {
  value       = aws_s3_bucket.flow_logs.bucket
  description = "S3 bucket name for Flow Logs"
}

output "flow_logs_bucket_arn" {
  value       = aws_s3_bucket.flow_logs.arn
  description = "S3 bucket ARN for Flow Logs"
}

output "vpc_flow_log_id" {
  value       = aws_flow_log.vpc.id
  description = "Flow log ID"
}
