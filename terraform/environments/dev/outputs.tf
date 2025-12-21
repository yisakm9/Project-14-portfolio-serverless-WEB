output "s3_bucket_name" {
  description = "The name of the S3 bucket created for the frontend"
  value       = module.frontend_bucket.bucket_id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = module.frontend_bucket.bucket_arn
}

output "s3_bucket_domain_name" {
  description = "The regional domain name of the bucket (used for CloudFront Origin)"
  value       = module.frontend_bucket.bucket_regional_domain_name
}