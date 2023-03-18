resource "aws_s3_bucket" "new_website_bucket" {
  bucket = "new-website-bucket"
}

resource "aws_s3_bucket_acl" "new_website_acl" {
  bucket = aws_s3_bucket.new_website_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_website_configuration" "new_website_config" {
  bucket = aws_s3_bucket.new_website_bucket.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }

}

resource "aws_s3_bucket_policy" "new_website_policty" {
  bucket = aws_s3_bucket.new_website_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "AllowGetObjects"
    Statement = [
      {
        Sid       = "AllowPublic"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.new_website_bucket.arn}/**"
      }
    ]
  })
}


locals {
  s3_origin_id = "s3-new-website.com"
}

resource "aws_cloudfront_distribution" "new_website_distribution" {
  
  enabled = true
  
  origin {
    origin_id                = local.s3_origin_id
    domain_name              = aws_s3_bucket.new_website_bucket.bucket_regional_domain_name
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1"]
    }
  }

  default_cache_behavior {
    target_origin_id = local.s3_origin_id
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }
  
  viewer_certificate {
    cloudfront_default_certificate = true
  }
  
}