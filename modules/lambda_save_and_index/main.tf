resource "aws_iam_role" "lambda_role" {
  name = "${var.function_name}_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "dynamodb_write" {
  name = "AllowDynamoWrite"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = ["dynamodb:PutItem"],
      Resource = "*"
    }]
  })
}

resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role          = aws_iam_role.lambda_role.arn
  runtime       = "python3.12"
  handler       = "save_and_index.lambda_handler"
  timeout       = 30

  filename         = "${path.module}/lambda_payload.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_payload.zip")

  environment {
    variables = {
      DYNAMO_TABLE_NAME = var.dynamodb_table_name
    }
  }

  tags = var.tags
}

resource "aws_iam_role_policy" "invoke_save_and_index" {
  name = "AllowLambdaInvokeSaveAndIndex"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "lambda:InvokeFunction",
        Resource = var.save_and_index_lambda_arn
      }
    ]
  })
}

resource "aws_iam_policy" "allow_opensearch_put" {
  name = "AllowOpenSearchPut"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement: [
      {
        Effect: "Allow",
        Action: [
          "es:ESHttpPut",
          "es:ESHttpPost"
        ],
        Resource: "arn:aws:es:us-east-1:*:domain/intellidoc-engine/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_opensearch_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.allow_opensearch_put.arn
}
