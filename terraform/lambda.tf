resource "aws_lambda_function" "api_lambda" {
  function_name = "${var.project_name}-${var.stage}-lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "handler.lambda_handler"
  runtime       = "python3.11"
  filename      = "${path.module}/../lambda/lambda_function.zip"

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.items_table.name
    }
  }
}
