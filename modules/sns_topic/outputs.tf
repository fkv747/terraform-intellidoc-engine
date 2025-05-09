output "sns_topic_arn" {
  value = aws_sns_topic.this.arn
}

output "textract_role_arn" {
  value = aws_iam_role.textract_publish_role.arn
}
