#  Security Headers Policy (OWASP Best Practices)
resource "aws_cloudfront_response_headers_policy" "security_headers" {
  name = "${var.project_name}-security-headers-${var.environment}"

  security_headers_config {
    # Protects against Clickjacking
    frame_options {
      frame_option = "DENY"
      override     = true
    }

    # Protects against MIME sniffing
    content_type_options {
      override = true
    }

    # Protects against XSS attacks
    xss_protection {
      mode_block = true
      protection = true
      override   = true
    }

    # Enforces HTTPS
    strict_transport_security {
      access_control_max_age_sec = 31536000 # 1 year
      include_subdomains         = true
      preload                    = true
      override                   = true
    }

    # Prevents sensitive info from being sent in the Referer header
    referrer_policy {
      referrer_policy = "strict-origin-when-cross-origin"
      override        = true
    }
  }
}

# 1. Create Origin Access Control (The modern way to secure S3)
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "${var.project_name}-oac-${var.environment}"
  description                       = "OAC for ${var.project_name} S3 Frontend"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# 2. Create the Distribution
resource "aws_cloudfront_distribution" "s3_distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100" # Use PriceClass_All for global, 100 is cheapest (US/EU)

  # Origin Configuration (Pointing to S3)
  origin {
    domain_name              = var.s3_bucket_domain_name
    origin_id                = "S3-${var.project_name}"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  # Caching Behavior
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.project_name}"
    response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers.id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # React Router Fix: Redirect 404/403 to index.html
  # This enables "Client Side Routing" so refreshing a page like /about doesn't crash
  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }

  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = var.tags
}
# Auto-publish Distribution ID to SSM
resource "aws_ssm_parameter" "cloudfront_id" {
  name        = "/${var.project_name}/${var.environment}/cloudfront_id"
  description = "The CloudFront Distribution ID"
  type        = "String"
  value       = aws_cloudfront_distribution.s3_distribution.id
  tags        = var.tags
}