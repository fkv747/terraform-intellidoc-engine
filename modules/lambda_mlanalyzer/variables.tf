variable "function_name" {
  type        = string
  description = "Name of the Lambda function"
}

variable "tags" {
  type        = map(string)
  description = "Tags for resources"
}

variable "save_and_index_lambda_arn" {
  type        = string
  description = "ARN of the SaveAndIndex Lambda"
}
