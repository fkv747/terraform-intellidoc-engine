# S3 Bucket
module "s3_bucket" {
  source           = "./modules/s3_bucket"
  bucket_name      = "intellidoc-input-bucket"
  enable_versioning = true
  tags = {
    Project = "IntelliDoc Engine"
    Env     = "dev"
  }
}

# Lambda - Textract Processor
module "lambda_textract_processor" {
  source             = "./modules/lambda_textract_processor"
  function_name      = "TextractProcessor"
  lambda_role_arn    = module.iam_role_textract_processor.role_arn
  sns_topic_arn      = module.sns_topic.sns_topic_arn
  textract_role_arn  = module.sns_topic.textract_role_arn

  tags = {
    Project = "IntelliDoc Engine"
    Env     = "dev"
  }
}

module "lambda_mlanalyzer" {
  source         = "./modules/lambda_mlanalyzer"
  function_name  = "MLAnalyzer"
  save_and_index_lambda_arn = module.lambda_save_and_index.lambda_arn

  tags = {
    Project = "IntelliDoc Engine"
    Env     = "dev"
  }
}

module "iam_role_textract_processor" {
  source    = "./modules/iam-role"
  role_name = "TextractProcessor_role_v2"
}

# SNS Topic
module "sns_topic" {
  source     = "./modules/sns_topic"
  topic_name = "TextractJobResults"
  tags = {
    Project = "IntelliDoc Engine"
    Env     = "dev"
  }
}

resource "aws_lambda_permission" "sns_invoke_mlanalyzer" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_mlanalyzer.lambda_name
  principal     = "sns.amazonaws.com"
  source_arn    = module.sns_topic.sns_topic_arn
}

resource "aws_sns_topic_subscription" "mlanalyzer_sub" {
  topic_arn = module.sns_topic.sns_topic_arn
  protocol  = "lambda"
  endpoint  = module.lambda_mlanalyzer.lambda_arn
}

module "dynamodb_table" {
  source     = "./modules/dynamodb_table"
  table_name = "IntelliDocMetadata"
  tags = {
    Project = "IntelliDoc Engine"
    Env     = "dev"
  }
}

module "lambda_save_and_index" {
  source                  = "./modules/lambda_save_and_index"
  function_name           = "SaveAndIndex"
  dynamodb_table_name     = module.dynamodb_table.table_name
  save_and_index_lambda_arn = module.lambda_save_and_index.lambda_arn

  tags = {
    Project = "IntelliDoc Engine"
    Env     = "dev"
  }
}

module "opensearch" {
  source      = "./modules/opensearch"
  domain_name = "intellidoc-engine"
}
