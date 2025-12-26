variable "aws_region" {
  description = "The AWS region to deploy resources into"
  type        = string
  default     = "us-east-1" 
}

variable "project_name" {
  description = "Project naming convention"
  type        = string
  default     = "yisak-portfolio"
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}
variable "sender_email" {
  description = "The verified SES email address"
  type        = string
  default     = "yisakmesifin@gmail.com"
}