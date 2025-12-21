output "bucket_id" {
  description = "The name of the bucket"
  value       = aws_s3_bucket.website_bucket.id
}

output "bucket_arn" {
  description = "The ARN of the bucket"
  value       = aws_s3_bucket.website_bucket.arn
}

output "bucket_regional_domain_name" {
  description = "The bucket domain name. Will be used by CloudFront."
  value       = aws_s3_bucket.website_bucket.bucket_regional_domain_name
}