output "lambda_function_arn" {
  value = aws_lambda_function.search_opensearch.arn
}

output "lambda_function_name" {
  value = aws_lambda_function.search_opensearch.function_name
}
