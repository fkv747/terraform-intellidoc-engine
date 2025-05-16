variable "lambda_arn" {
  description = "ARN of the Lambda function to integrate"
  type        = string
}

variable "lambda_name" {
  description = "Name of the Lambda function to allow invoke"
  type        = string
}

variable "search_lambda_arn" {
  type        = string
  description = "ARN of the SearchOpenSearch Lambda"
}

variable "search_lambda_name" {
  type        = string
  description = "Name of the SearchOpenSearch Lambda"
}

variable "api_name" {
  type        = string
  description = "Name of the HTTP API"
}
