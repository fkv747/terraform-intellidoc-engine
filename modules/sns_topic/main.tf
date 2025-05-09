resource "aws_sns_topic" "this" {
  name = var.topic_name
  tags = var.tags
}

resource "aws_iam_role" "textract_publish_role" {
  name = "${var.topic_name}_publisher_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "textract.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "publish_policy" {
  name = "AllowSNSPublish"
  role = aws_iam_role.textract_publish_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = "sns:Publish",
      Resource = aws_sns_topic.this.arn
    }]
  })
}

