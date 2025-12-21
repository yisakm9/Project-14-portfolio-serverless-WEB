variable "function_name" { type = string }
variable "iam_role_arn" { type = string }
variable "source_file" { type = string }
variable "environment_variables" { type = map(string) }
variable "tags" { type = map(string) }