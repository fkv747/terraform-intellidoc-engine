resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role = var.lambda_role_arn
  runtime       = "python3.12"
  handler       = "textract.lambda_handler"
  timeout       = 30

  filename         = "${path.module}/lambda_payload.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_payload.zip")

  tags = var.tags

  environment {
    variables = {
      SNS_TOPIC_ARN   = var.sns_topic_arn
      TEXTRACT_ROLE_ARN = var.textract_role_arn
    }
  }
}

# This block is used to set up the S3 bucket notification configuration
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::intellidoc-input-bucket"
}

resource "aws_s3_bucket_notification" "s3_trigger" {
  bucket = "intellidoc-input-bucket"

  lambda_function {
    lambda_function_arn = aws_lambda_function.this.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}
