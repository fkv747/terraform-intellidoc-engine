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

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role          = aws_iam_role.lambda_role.arn
  runtime       = "python3.12"
  handler       = "mlanalyzer.lambda_handler"
  timeout       = 30

  filename         = "${path.module}/lambda_payload.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_payload.zip")

  tags = var.tags
  
}

resource "aws_iam_role_policy" "textract_read_results" {
  name = "AllowTextractReadResults"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "textract:GetDocumentTextDetection"
      ],
      Resource = "*"
    }]
  })
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

resource "aws_iam_role_policy" "mlanalyzer_sagemaker_access" {
  name = "AllowInvokeSageMaker"
  role = aws_iam_role.lambda_role.name  # ✅ Correct reference to your actual role

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "sagemaker:InvokeEndpoint",
        Resource = "*"  # You can restrict this later if needed
      }
    ]
  })
}

resource "aws_iam_role_policy" "sagemaker_invoke" {
  name = "AllowSageMakerInvoke"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sagemaker:InvokeEndpoint"
        ],
        Resource = "*"  # Can be restricted later
      }
    ]
  })
}
