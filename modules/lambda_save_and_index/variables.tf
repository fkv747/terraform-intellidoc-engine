variable "function_name" {
  type        = string
  description = "Name of the SaveAndIndex Lambda"
}

variable "dynamodb_table_name" {
  type        = string
  description = "DynamoDB table to write into"
}

variable "tags" {
  type        = map(string)
  default     = {}
}

variable "save_and_index_lambda_arn" {
  type        = string
  description = "ARN of the SaveAndIndex Lambda"
}
