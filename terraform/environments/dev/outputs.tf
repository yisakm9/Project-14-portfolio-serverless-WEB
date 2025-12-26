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
output "api_base_url" {
  description = "The Base URL for the API Gateway"
  value       = module.api_gateway.api_endpoint
}

output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution (used for cache invalidation)"
  value       = module.cloudfront.distribution_id
}

output "cloudfront_domain_name" {
  description = "The public URL of your website"
  value       = module.cloudfront.distribution_domain_name
}

output "cloudfront_distribution_arn" {
  description = "The ARN of the CloudFront distribution"
  value       = module.cloudfront.distribution_arn
}