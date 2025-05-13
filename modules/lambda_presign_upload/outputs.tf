output "lambda_presign_arn" {
  description = "ARN of the presign upload Lambda"
  value       = aws_lambda_function.presign_upload.arn
}
