# environments/dev/providers.tf
terraform {
  required_version = ">= 1.13.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  # Default tags apply to ALL resources created by this provider
  default_tags {
    tags = {
      Project     = "YisakPortfolio"
      Environment = "Dev"
      ManagedBy   = "Terraform"
      Owner       = "Yisak Mesifin"
    }
  }
}