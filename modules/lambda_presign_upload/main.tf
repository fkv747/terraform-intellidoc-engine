resource "aws_iam_role" "lambda_role" {
  name = "lambda_presign_upload_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "s3_write_policy" {
  name = "lambda_presign_upload_s3_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "s3:PutObject"
        Resource = "arn:aws:s3:::${var.upload_bucket}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.s3_write_policy.arn
}

resource "null_resource" "zip_lambda" {
  provisioner "local-exec" {
    command = "cd ${path.module} && zip lambda_payload.zip presign_upload.py"
  }

  triggers = {
    always_run = timestamp()
  }
}

resource "aws_lambda_function" "presign_upload" {
  function_name = "PresignUpload"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "python3.12"
  handler       = "presign_upload.lambda_handler"
  filename      = "${path.module}/lambda_payload.zip"

  source_code_hash = filebase64sha256("${path.module}/lambda_payload.zip")

  environment {
    variables = {
      UPLOAD_BUCKET = var.upload_bucket
    }
  }

  depends_on = [null_resource.zip_lambda]
}
