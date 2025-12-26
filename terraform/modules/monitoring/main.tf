resource "aws_cloudwatch_dashboard" "portfolio_dashboard" {
  dashboard_name = "${var.project_name}-dashboard-${var.environment}"

  dashboard_body = jsonencode({
    widgets = [
      # Row 1: Traffic Overview
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/CloudFront", "Requests", "DistributionId", var.cloudfront_id],
            [".", "4xxErrorRate", ".", "."],
            [".", "5xxErrorRate", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "Frontend Traffic & Errors"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApiGateway", "Count", "ApiId", var.api_id],
            [".", "4xx", ".", "."],
            [".", "5xx", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "API Gateway Hits"
          period  = 300
        }
      },
      # Row 2: Lambda Performance
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 24
        height = 6
        properties = {
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", var.lambda_contact_name],
            [".", "Errors", ".", "."],
            [".", "Duration", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "Contact Form Health"
          period  = 300
        }
      }
    ]
  })
}