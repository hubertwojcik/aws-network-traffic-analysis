output "guardduty_detector_id" {
  value       = aws_guardduty_detector.this.id
  description = "GuardDuty detector ID"
}

output "ir_lambda_name" {
  value       = aws_lambda_function.ir.function_name
  description = "IR Lambda function name"
}
