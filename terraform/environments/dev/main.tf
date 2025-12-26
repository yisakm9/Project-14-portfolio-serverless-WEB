resource "random_pet" "suffix" {
  length = 2
}

module "frontend_bucket" {
  source = "../../modules/s3_website"

  # We use a variable here to keep the environment flexible
  bucket_name = "${var.project_name}-frontend-${var.environment}-${random_pet.suffix.id}"
  
  project_name = var.project_name
  environment  = var.environment
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

# 3. S3 Access Policy (NEW: Glue Module)
# This attaches the policy cleanly without causing circular dependencies
module "frontend_security_policy" {
  source                      = "../../modules/s3_access_policy"
  bucket_id                   = module.frontend_bucket.bucket_id
  bucket_arn                  = module.frontend_bucket.bucket_arn
  cloudfront_distribution_arn = module.cloudfront.distribution_arn
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
  sender_email       = var.sender_email
  
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
     # LINK: Use the email from the SES module
    SENDER_EMAIL   = module.ses.email_address 
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
    
    # 2. Get Projects 
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

# 13. Monitoring Dashboard
module "monitoring" {
  source = "../../modules/monitoring"

  project_name      = var.project_name
  environment       = var.environment
  
  # Connect the dots between resources
  cloudfront_id     = module.cloudfront.distribution_id
  api_id            = module.api_gateway.api_id
  lambda_contact_name = module.lambda_contact.function_name
}

# 14. SES Email Identity (Automated Verification Request)
module "ses" {
  source        = "../../modules/ses"
  email_address = "yisakmesifin@gmail.com" # Terraform will ask AWS to verify this
}