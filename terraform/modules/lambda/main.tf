# 1. Zip the Python Code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = var.source_file
  output_path = "${path.module}/lambda_function.zip"
}

# 0. Explicit Log Group Management (Cost Optimization)
# Prevents logs from being stored forever
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 30 # Keep logs for 1 month only
  
  tags = var.tags
}
# 2. Create the Lambda Function
resource "aws_lambda_function" "this" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = var.function_name
  role          = var.iam_role_arn
  handler       = "main.handler" # filename.function_name
  runtime       = "python3.10"
  timeout       = 10

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = var.environment_variables
  }

  tags = var.tags
  depends_on = [aws_cloudwatch_log_group.lambda_log_group]
}