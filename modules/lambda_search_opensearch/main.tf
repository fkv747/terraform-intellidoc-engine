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

resource "aws_iam_policy" "opensearch_policy" {
  name = "lambda_search_opensearch_policy"
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
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.opensearch_policy.arn
}

resource "aws_lambda_function" "search_opensearch" {
  function_name = "SearchOpenSearch"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "python3.12"
  handler       = "search_opensearch.lambda_handler"

  filename         = "${path.module}/lambda_payload.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_payload.zip")

  environment {
    variables = {
      OPENSEARCH_URL   = var.opensearch_url
      OPENSEARCH_INDEX = var.opensearch_index
      REGION           = var.aws_region
    }
  }
}

