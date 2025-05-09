variable "function_name" {
  type        = string
  description = "Name of the Lambda function"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the Lambda function"
}


variable "lambda_role_arn" {
  type        = string
  description = "IAM role ARN for the Lambda function"
}

variable "sns_topic_arn" {
  type        = string
  description = "SNS topic ARN to notify when Textract job completes"
}

variable "textract_role_arn" {
  type        = string
  description = "IAM Role ARN that Textract will assume to publish to SNS"
}
