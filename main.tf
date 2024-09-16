locals {
  main_domain           = one(slice(var.domains, 0, 1))
  alternative_domains   = length(var.domains) == 1 ? [] : slice(var.domains, 1, length(var.domains))
  main_domain_sanitized = replace(local.main_domain, "*.", "")
  tags = merge({
    Name : local.main_domain_sanitized
  }, var.tags)
}

module "certificate" {
  providers = {
    aws = aws.us_east_1
  }

  source  = "terraform-aws-modules/acm/aws"
  version = "4.3.2"

  domain_name = local.main_domain
  zone_id     = var.domain_zone_id

  subject_alternative_names = local.alternative_domains

  wait_for_validation = true

  tags = local.tags
}

resource "aws_cloudfront_origin_access_identity" "this" {
  comment = "Access from CF to S3 - ${local.main_domain}"
}

resource "aws_cloudfront_origin_access_control" "this" {
  name                              = "Access from CF to S3 - ${local.main_domain}"
  description                       = "Access from CF to S3 - ${local.main_domain}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${var.s3_bucket_name_create}/*",
    ]

    principals {
      type = "AWS"

      identifiers = [
        aws_cloudfront_origin_access_identity.this.iam_arn,
      ]
    }
  }
}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.10.1"

  bucket = var.s3_bucket_name_create

  attach_policy = true
  policy        = data.aws_iam_policy_document.bucket_policy.json

  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true

  logging = var.logs_bucket == null ? {} : {
    target_bucket = var.logs_bucket
    target_prefix = "s3/access_log/${var.s3_bucket_name_create}"
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = local.tags
}

resource "aws_cloudfront_distribution" "this" {
  comment = local.main_domain

  origin {
    domain_name = var.s3_bucket_name_create == var.s3_bucket_name ? module.s3_bucket.s3_bucket_bucket_regional_domain_name : var.s3_bucket_bucket_regional_domain_name
    origin_id   = var.s3_bucket_name
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
  }

  aliases = var.domains

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  custom_error_response {
    error_caching_min_ttl = 3000
    error_code            = 404
    response_code         = var.override_status_code_404
    response_page_path    = "/index.html"
  }

  custom_error_response {
    error_caching_min_ttl = 3000
    error_code            = 403
    response_code         = var.override_status_code_403
    response_page_path    = "/index.html"
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.s3_bucket_name

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

  price_class = var.cloudfront_price_class

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = module.certificate.acm_certificate_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2018"
  }

  tags = local.tags
}

resource "aws_route53_record" "this" {
  for_each = toset(var.domains)

  zone_id = var.domain_zone_id
  name    = each.value
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = false
  }
}
