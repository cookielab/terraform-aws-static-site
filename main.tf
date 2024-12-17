locals {
  main_domain           = one(slice(var.domains, 0, 1))
  alternative_domains   = length(var.domains) == 1 ? [] : slice(var.domains, 1, length(var.domains))
  main_domain_sanitized = replace(local.main_domain, "*.", "")
  custom_headers        = var.custom_headers != {} || length(var.s3_cors_rule) > 0 ? true : false
  tags = merge({
    Name : local.main_domain_sanitized
  }, var.tags)
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

module "certificate" {
  providers = {
    aws = aws.us_east_1
  }

  source  = "terraform-aws-modules/acm/aws"
  version = "5.1.1"

  domain_name = local.main_domain
  zone_id     = var.domain_zone_id

  subject_alternative_names = concat(local.alternative_domains, keys(var.extra_domains))

  validation_method   = "DNS"
  wait_for_validation = true

  zones = var.extra_domains

  tags = local.tags
}

resource "aws_cloudfront_origin_access_control" "this" {
  name                              = "Access from CF to S3 - ${local.main_domain}"
  description                       = "Access from CF to S3 - ${local.main_domain}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_origin_access_identity" "this" {
  comment = "Deprecated: Access from CF to S3 - ${local.main_domain} - Superseeded by OAC"
}

data "aws_iam_policy_document" "s3_bucket_policy" {
  override_policy_documents = [
    var.s3_bucket_policy,
  ]

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

resource "aws_kms_key" "this" {
  count                   = var.encrypt_with_kms ? 1 : 0
  description             = "This key is used to encrypt the S3 bucket ${var.s3_bucket_name}"
  enable_key_rotation     = true
  deletion_window_in_days = var.kms_deletion_window_in_days
  tags                    = local.tags
}

resource "aws_kms_alias" "this" {
  count         = var.encrypt_with_kms ? 1 : 0
  name          = "alias/s3/${var.s3_bucket_name}"
  target_key_id = aws_kms_key.this[0].key_id
}

resource "aws_kms_key_policy" "this" {
  count  = var.encrypt_with_kms ? 1 : 0
  key_id = aws_kms_key.this[0].key_id
  policy = data.aws_iam_policy_document.kms_key_policy.json
}

data "aws_iam_policy_document" "kms_key_policy" {
  override_policy_documents = [
    var.kms_key_policy,
  ]

  dynamic "statement" {
    for_each = var.encrypt_with_kms ? [1] : []
    content {
      sid    = "Allow root privs"
      effect = "Allow"
      actions = [
        "kms:*"
      ]
      resources = ["*"]
      principals {
        type        = "AWS"
        identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.id}:root"]
      }
    }
  }

  dynamic "statement" {
    for_each = var.encrypt_with_kms && var.enable_deploy_user ? [1] : []
    content {
      sid = "Allow deploy user to use the CMK"
      actions = [
        "kms:GenerateDataKey*",
        "kms:Encrypt",
        "kms:Decrypt"
      ]
      resources = ["*"]

      principals {
        type        = "AWS"
        identifiers = [aws_iam_user.deploy[0].arn]
      }
      effect = "Allow"
    }
  }

  statement {
    sid    = "Allow CloudFront usage of the key"
    effect = "Allow"
    actions = [
      "kms:GenerateDataKey*",
      "kms:Encrypt",
      "kms:Decrypt",
    ]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"

      values = [
        aws_cloudfront_distribution.this.arn
      ]
    }
  }
}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.6.0"

  bucket = var.s3_bucket_name

  attach_policy = true
  policy        = data.aws_iam_policy_document.s3_bucket_policy.json

  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true

  logging = var.logs_bucket == null ? {} : {
    target_bucket = var.logs_bucket
    target_prefix = "s3/access_log/${var.s3_bucket_name}"
  }

  expected_bucket_owner = data.aws_caller_identity.current.account_id

  server_side_encryption_configuration = {
    rule = {
      bucket_key_enabled = false
      apply_server_side_encryption_by_default = var.encrypt_with_kms ? {
        kms_master_key_id = aws_kms_key.this[0].arn
        sse_algorithm     = "aws:kms"
        } : {
        sse_algorithm = "AES256"
      }
    }
  }

  cors_rule = var.s3_cors_rule

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

  web_acl_id = var.waf_acl_arn
  origin {
    domain_name              = module.s3_bucket.s3_bucket_bucket_regional_domain_name
    origin_id                = var.s3_bucket_name
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
    origin_path              = var.origin_path
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

  aliases = concat(var.domains, keys(var.extra_domains))

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
    allowed_methods            = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods             = ["GET", "HEAD"]
    target_origin_id           = var.s3_bucket_name
    response_headers_policy_id = local.custom_headers ? aws_cloudfront_response_headers_policy.this[0].id : null

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = var.min_ttl
    default_ttl            = var.default_ttl
    max_ttl                = var.max_ttl

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
      restriction_type = var.restriction_type
      locations        = var.restrictions_locations
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

resource "aws_route53_record" "extra" {
  for_each = var.extra_domains

  zone_id = each.value
  name    = each.key
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_cloudfront_response_headers_policy" "this" {
  count   = local.custom_headers ? 1 : 0
  name    = "${var.s3_bucket_name}-headers"
  comment = "CloudFront response headers policy"

  dynamic "cors_config" {
    for_each = length(var.s3_cors_rule) > 0 ? [1] : []
    content {
      access_control_allow_credentials = var.response_header_access_control_allow_credentials

      access_control_allow_headers {
        items = var.s3_cors_rule[0].allowed_headers
      }

      access_control_allow_methods {
        items = var.s3_cors_rule[0].allowed_methods
      }

      access_control_allow_origins {
        items = var.s3_cors_rule[0].allowed_origins
      }

      origin_override = var.response_header_origin_override
    }
  }

  security_headers_config {
    dynamic "content_security_policy" {
      for_each = var.custom_headers.content_security_policy != null ? [1] : []
      content {
        content_security_policy = var.custom_headers.content_security_policy.policy
        override                = var.custom_headers.response_header_origin_override.override
      }
    }

    dynamic "content_type_options" {
      for_each = var.custom_headers.content_type_options != null ? [1] : []
      content {
        override = var.custom_headers.content_type_options.override
      }
    }

    dynamic "frame_options" {
      for_each = var.custom_headers.frame_options != null ? [1] : []
      content {
        frame_option = var.custom_headers.frame_options.frame_option
        override     = var.custom_headers.frame_options.override
      }
    }

    dynamic "referrer_policy" {
      for_each = var.custom_headers.referrer_policy != null ? [1] : []
      content {
        referrer_policy = var.custom_headers.referrer_policy.referrer_policy
        override        = var.custom_headers.referrer_policy.override
      }
    }

    dynamic "xss_protection" {
      for_each = var.custom_headers.xss_protection != null ? [1] : []
      content {
        mode_block = var.custom_headers.xss_protection.mode_block
        protection = var.custom_headers.xss_protection.protection
        override   = var.custom_headers.xss_protection.override
      }
    }

    dynamic "strict_transport_security" {
      for_each = var.custom_headers.strict_transport_security != null ? [1] : []
      content {
        access_control_max_age_sec = var.custom_headers.strict_transport_security.access_control_max_age_sec
        include_subdomains         = var.custom_headers.strict_transport_security.include_subdomains
        preload                    = var.custom_headers.strict_transport_security.preload
        override                   = var.custom_headers.strict_transport_security.override
      }
    }
  }

  custom_headers_config {
    dynamic "items" {
      for_each = var.custom_headers != {} && var.custom_headers.headers != null ? var.custom_headers.headers : {}
      content {
        header   = items.key
        value    = items.value.value
        override = items.value.override
      }
    }
  }

}

moved {
  from = aws_kms_key.this
  to   = aws_kms_key.this[0]
}

moved {
  from = aws_kms_alias.this
  to   = aws_kms_alias.this[0]
}

moved {
  from = aws_kms_key_policy.this
  to   = aws_kms_key_policy.this[0]
}
