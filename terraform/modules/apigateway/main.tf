resource "aws_apigatewayv2_api" "this" {
  name          = "${var.project_name}-api-${var.environment}"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = var.allowed_origins
    allow_methods = ["POST", "GET", "OPTIONS"]
    allow_headers = ["Content-Type", "Authorization"]
    max_age       = 300
  }

  tags = var.tags
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = "$default"
  auto_deploy = true
  tags        = var.tags
}

# ---------------------------------------------------------
# DYNAMIC CONFIGURATION (Loops through var.integrations)
# ---------------------------------------------------------

# 1. Integration (Connects API to Lambda)
resource "aws_apigatewayv2_integration" "lambda_integration" {
  for_each = var.integrations

  api_id           = aws_apigatewayv2_api.this.id
  integration_type = "AWS_PROXY"
  
  integration_uri        = each.value.lambda_invoke_arn
  integration_method     = "POST" # AWS_PROXY always uses POST to talk to Lambda
  payload_format_version = "2.0"
}

# 2. Route (Defines the URL path)
resource "aws_apigatewayv2_route" "route" {
  for_each = var.integrations

  api_id    = aws_apigatewayv2_api.this.id
  route_key = each.value.route_key
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration[each.key].id}"
}

# 3. Permission (Allows API GW to call Lambda)
resource "aws_lambda_permission" "api_gw_permission" {
  for_each = var.integrations

  statement_id  = "AllowExecutionFromAPIGateway-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.lambda_function_name
  principal     = "apigateway.amazonaws.com"

  # Uses the route key to lock down permissions (e.g., allow POST /contact only)
  source_arn = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
}