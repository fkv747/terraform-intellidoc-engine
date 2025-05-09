resource "aws_dynamodb_table" "this" {
  name           = var.table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "DocumentId"

  attribute {
    name = "DocumentId"
    type = "S"
  }

  tags = var.tags
}
