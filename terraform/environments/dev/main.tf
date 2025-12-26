resource "random_pet" "suffix" {
  length = 2
}

module "frontend_bucket" {
  source = "../../modules/s3_website"

  # We use a variable here to keep the environment flexible
  bucket_name = "${var.project_name}-frontend-${var.environment}-${random_pet.suffix.id}"
  
  tags = {
    Environment = var.environment
    Type        = "Frontend"
  }
}
# 2. CloudFront Module (CORRECTED)
module "cloudfront" {
  source = "../../modules/cloudfront"

  project_name = var.project_name
  environment  = var.environment

  
  s3_bucket_domain_name = module.frontend_bucket.bucket_regional_domain_name 

  tags = {
    Environment = var.environment
  }
}


resource "aws_s3_bucket_policy" "allow_cloudfront" {
  bucket = module.frontend_bucket.bucket_id 

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipal"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action    = "s3:GetObject"
        Resource  = "${module.frontend_bucket.bucket_arn}/*" 
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = module.cloudfront.distribution_arn
          }
        }
      }
    ]
  })
}


module "dynamodb_table" {
  source     = "../../modules/dynamodb"
  table_name = "${var.project_name}-contact-messages-${var.environment}"

  tags = {
    Environment = var.environment
  }
}


module "iam" {
  source             = "../../modules/iam"
  project_name       = var.project_name
  environment        = var.environment
  dynamodb_table_arn = module.dynamodb_table.table_arn
  
  tags = {
    Environment = var.environment
  }
}


module "lambda_contact" {
  source       = "../../modules/lambda"
  
  function_name = "${var.project_name}-contact-${var.environment}"
  iam_role_arn  = module.iam.lambda_execution_role_arn
  
  # Point to the Python file we created in Step 2
  # Note: Use ${path.module} to reference from the dev folder back to root
  source_file   = "${path.module}/../../../backend/contact_form/main.py"

  environment_variables = {
    DYNAMODB_TABLE = module.dynamodb_table.table_name
  }

  tags = {
    Environment = var.environment
  }
}


module "api_gateway" {
  source = "../../modules/apigateway"

  project_name    = var.project_name
  environment     = var.environment
  allowed_origins = ["*"]

  # Pass BOTH Integrations now
  integrations = {
    # 1. Contact Form
    "contact_form" = {
      lambda_arn           = module.lambda_contact.function_arn
      lambda_invoke_arn    = module.lambda_contact.invoke_arn
      lambda_function_name = module.lambda_contact.function_name
      route_key            = "POST /contact"
    }
    
    # 2. Get Projects (NEW)
    "get_projects" = {
      lambda_arn           = module.lambda_projects.function_arn
      lambda_invoke_arn    = module.lambda_projects.invoke_arn
      lambda_function_name = module.lambda_projects.function_name
      route_key            = "GET /projects"
    }
  }

  tags = {
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "api_url" {
  name        = "/${var.project_name}/${var.environment}/api_url"
  description = "The Base URL for the API Gateway"
  type        = "String"
  value       = module.api_gateway.api_endpoint

  tags = {
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "frontend_bucket" {
  name        = "/${var.project_name}/${var.environment}/frontend_bucket"
  description = "The S3 bucket name for the frontend"
  type        = "String"
  value       = module.frontend_bucket.bucket_id

  tags = {
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "cloudfront_id" {
  name        = "/${var.project_name}/${var.environment}/cloudfront_id"
  description = "The CloudFront Distribution ID"
  type        = "String"
  value       = module.cloudfront.distribution_id

  tags = {
    Environment = var.environment
  }
}

# 12. Lambda: Get Projects (NEW)
module "lambda_projects" {
  source        = "../../modules/lambda"
  function_name = "${var.project_name}-get-projects-${var.environment}"
  iam_role_arn  = module.iam.lambda_execution_role_arn
  
  source_file   = "${path.module}/../../../backend/get_projects/main.py"

  environment_variables = {
    GITHUB_USERNAME = "yisakm9" # REPLACE THIS
  }

  tags = {
    Environment = var.environment
  }
}