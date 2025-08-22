resource "aws_dynamodb_table" "items_table" {
  name           = "${var.project_name}-${var.stage}-items"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}
