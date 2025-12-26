resource "aws_s3_bucket" "website_bucket" {
  bucket = var.bucket_name

  

  tags = var.tags
}

# 1. Enable Versioning (Safety best practice)
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.website_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 2. Server-Side Encryption (Security best practice)
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.website_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 3. Block Public Access (Security best practice)
# We strictly block public access. Only CloudFront will read this bucket.
resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# Auto-publish Bucket Name to SSM
resource "aws_ssm_parameter" "frontend_bucket" {
  # Note: You need to pass 'project_name' and 'environment' variables to this module now if not already there
  name        = "/${var.project_name}/${var.environment}/frontend_bucket"
  description = "The S3 bucket name for the frontend"
  type        = "String"
  value       = aws_s3_bucket.website_bucket.id
  tags        = var.tags
}