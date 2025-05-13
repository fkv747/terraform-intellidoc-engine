output "upload_api_url" {
  description = "API Gateway invoke URL for presigned upload"
  value       = aws_apigatewayv2_api.upload_api.api_endpoint
}
