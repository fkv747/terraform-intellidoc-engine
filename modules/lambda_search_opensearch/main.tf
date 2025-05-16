resource "aws_iam_role" "lambda_role" {
  name = "lambda_search_opensearch_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "opensearch_inline" {
  name = "AllowOpenSearchFromLambda"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "es:ESHttpGet",
          "es:ESHttpPost"
        ],
        Resource = "${var.opensearch_domain_arn}/*"
      },
      {
        Effect = "Allow",
        Action = "kms:Decrypt",
        Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_function" "search_opensearch" {
  function_name = "SearchOpenSearch"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "python3.12"
  handler       = "search_opensearch.lambda_handler"

  filename         = "${path.module}/lambda_payload.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_payload.zip")
  kms_key_arn = aws_kms_key.lambda_key.arn

  environment {
    variables = {
      OPENSEARCH_URL   = var.opensearch_url
      OPENSEARCH_INDEX = var.opensearch_index
      REGION           = var.aws_region
    }
  }
}

resource "aws_kms_key" "lambda_key" {
  description = "KMS key for SearchOpenSearch Lambda env vars"
  enable_key_rotation = true

  policy = jsonencode({
    Version = "2012-10-17",
    Statement: [
      {
        Sid: "AllowLambdaDecrypt",
        Effect: "Allow",
        Principal: {
          AWS = "arn:aws:iam::245994248859:role/lambda_search_opensearch_role"
        },
        Action: "kms:Decrypt",
        Resource: "*"
      },
      {
        Sid: "AllowAccountAdmin",
        Effect: "Allow",
        Principal: {
          AWS = "arn:aws:iam::245994248859:root"
        },
        Action: "kms:*",
        Resource: "*"
      }
    ]
  })
}


resource "aws_iam_role_policy" "allow_all_opensearch" {
  name = "AllowAllOpenSearchAccess"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "es:*",
        Resource = "*"
      }
    ]
  })
}
