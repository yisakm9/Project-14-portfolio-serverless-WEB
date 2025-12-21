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