module "frontend_bucket" {
  source = "../../modules/s3_website"

  # We use a variable here to keep the environment flexible
  bucket_name = "${var.project_name}-frontend-${var.environment}"
  
  tags = {
    Environment = var.environment
    Type        = "Frontend"
  }
}