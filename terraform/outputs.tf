output "api_invoke_url" {
  value       = "https://${aws_api_gateway_rest_api.api.id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_stage.prod.stage_name}"
  description = "Invoke URL for the API Gateway prod stage"
}

output "lambda_name" {
  value       = aws_lambda_function.api_lambda.function_name
  description = "Name of the Lambda function"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.items_table.name
  description = "Name of the DynamoDB table"
}

output "sns_topic_arn" {
  value       = aws_sns_topic.alerts.arn
  description = "SNS topic ARN for alerts"
}
