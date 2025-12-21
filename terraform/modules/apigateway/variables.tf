variable "project_name" { type = string }
variable "environment" { type = string }
variable "tags" { type = map(string) }

variable "allowed_origins" {
  description = "List of allowed origins for CORS"
  type        = list(string)
  default     = ["*"] # Default to open, but we will lock this down in Prod
}

variable "integrations" {
  description = "Map of Lambda integrations. Key is a unique ID, value contains route and lambda details."
  type = map(object({
    lambda_arn           = string
    lambda_invoke_arn    = string
    lambda_function_name = string
    route_key            = string # e.g., "POST /contact"
  }))
  default = {}
}