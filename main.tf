locals {
  main_domain           = one(slice(var.domains, 0, 1))
  alternative_domains   = length(var.domains) == 1 ? [] : slice(var.domains, 1, length(var.domains))
  main_domain_sanitized = replace(local.main_domain, "*.", "")
  tags = merge({
    Name : local.main_domain_sanitized
  }, var.tags)
}

data "aws_region" "current" {}

module "certificate" {
  providers = {
    aws = aws.us_east_1
  }

  source  = "terraform-aws-modules/acm/aws"
  version = "5.0.0"

  domain_name = local.main_domain
  zone_id     = var.domain_zone_id

  subject_alternative_names = local.alternative_domains

  validation_method   = "DNS"
  wait_for_validation = true

  tags = local.tags
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
    sid = "AllowCloudFrontServicePrincipalReadOnly"
    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${var.s3_bucket_name}/*",
    ]

    principals {
      type = "Service"

      identifiers = [
        "cloudfront.amazonaws.com",
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.this.arn]
    }

  }
}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.2"

  bucket = var.s3_bucket_name

  attach_policy = true
  policy        = data.aws_iam_policy_document.bucket_policy.json

  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true

  logging = var.logs_bucket == null ? {} : {
    target_bucket = var.logs_bucket
    target_prefix = "s3/access_log/${var.s3_bucket_name}"
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

data "aws_cloudfront_origin_request_policy" "managed_all_viewer_and_cloudfront_headers" {
  name = "Managed-AllViewerAndCloudFrontHeaders-2022-06"
}

data "aws_cloudfront_cache_policy" "managed_caching_disabled" {
  name = "Managed-CachingDisabled"
}

resource "aws_cloudfront_distribution" "this" {
  comment = local.main_domain

  origin {
    domain_name              = module.s3_bucket.s3_bucket_bucket_regional_domain_name
    origin_id                = var.s3_bucket_name
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
  }

  dynamic "origin" {
    for_each = var.proxy_paths

    content {
      domain_name = origin.value.origin_domain
      origin_id   = origin.value.origin_domain

      custom_origin_config {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2", "TLSv1.1"]
      }
    }
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

    dynamic "function_association" {
      for_each = concat(
        var.functions.viewer_request == null ? [] : [
          {
            event_type   = "viewer-request",
            function_arn = var.functions.viewer_request
          }
        ],
        var.functions.viewer_response == null ? [] : [
          {
            event_type   = "viewer-response",
            function_arn = var.functions.viewer_response
          }
        ]
      )

      content {
        event_type   = function_association.value.event_type
        function_arn = function_association.value.function_arn
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.proxy_paths

    content {
      path_pattern     = "${ordered_cache_behavior.value.path_prefix}/*"
      allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
      cached_methods   = ["GET", "HEAD", "OPTIONS"]
      target_origin_id = ordered_cache_behavior.value.origin_domain

      viewer_protocol_policy = "redirect-to-https"

      origin_request_policy_id = data.aws_cloudfront_origin_request_policy.managed_all_viewer_and_cloudfront_headers.id
      cache_policy_id          = data.aws_cloudfront_cache_policy.managed_caching_disabled.id
    }
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

  dynamic "logging_config" {
    for_each = var.logs_bucket_domain_name == null ? [] : [1]

    content {
      bucket          = var.logs_bucket_domain_name
      prefix          = "cloudfront/access_logs/${local.main_domain_sanitized}/"
      include_cookies = false
    }
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
