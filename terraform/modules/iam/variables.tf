variable "project_name" { type = string }
variable "environment" { type = string }
variable "tags" { type = map(string) }

variable "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table to grant access to"
  type        = string
}