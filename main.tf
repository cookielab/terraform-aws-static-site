locals {
  main_domain  = var.zones_and_domains[0].domains[0]
  main_zone_id = var.zones_and_domains[0].zone_id

  all_domains = distinct(flatten([for z in var.zones_and_domains : z.domains]))

  alternative_domains = length(local.all_domains) == 1 ? [] : slice(local.all_domains, 1, length(local.all_domains))
  zones_by_domain = merge([
    for z in var.zones_and_domains : {
      for d in z.domains : d => z.zone_id
    }
  ]...)
  main_domain_sanitized  = replace(local.main_domain, "*.", "")
  custom_headers_present = var.custom_headers != null && var.custom_headers != {}
  custom_headers         = local.custom_headers_present || length(var.s3_cors_rule) > 0 ? true : false
  oidc_enabled           = length(var.oidc) == 0 ? false : true
  security_headers = var.custom_headers == null ? false : ((var.custom_headers.content_security_policy != null ||
    var.custom_headers.content_type_options != null ||
    var.custom_headers.frame_options != null ||
    var.custom_headers.referrer_policy != null ||
    var.custom_headers.xss_protection != null ||
  var.custom_headers.strict_transport_security != null) ? true : false)
  tags = merge({
    Name : local.main_domain_sanitized
  }, var.tags)
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_s3_bucket" "logs" {
  count = var.logs_bucket == null ? 0 : 1

  bucket = var.logs_bucket
}

data "aws_cloudfront_cache_policy" "managed_caching_disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_origin_request_policy" "managed_all_viewer_and_cloudfront_headers" {
  name = "Managed-AllViewerAndCloudFrontHeaders-2022-06"
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
      "${module.s3_bucket.s3_bucket_arn}/*",
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
      values   = [module.cdn.cloudfront_distribution_arn]
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
        identifiers = [module.deploy_identity.deploy_user_arn]
      }
      effect = "Allow"
    }
  }

  dynamic "statement" {
    for_each = var.encrypt_with_kms && var.enable_deploy_role ? [1] : []
    content {
      sid = "Allow deploy role to use the CMK"
      actions = [
        "kms:GenerateDataKey*",
        "kms:Encrypt",
        "kms:Decrypt"
      ]
      resources = ["*"]

      principals {
        type        = "AWS"
        identifiers = [module.deploy_identity.deploy_role_arn]
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
        module.cdn.cloudfront_distribution_arn
      ]
    }
  }
}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.10.0"

  bucket = var.s3_bucket_name

  attach_policy = true
  policy        = data.aws_iam_policy_document.s3_bucket_policy.json

  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true

  logging = var.logs_bucket == null ? {} : {
    target_bucket = data.aws_s3_bucket.logs[0].id
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

module "certificate" {
  providers = {
    aws = aws.us_east_1
  }

  source  = "terraform-aws-modules/acm/aws"
  version = "6.3.0"

  domain_name = local.main_domain
  zone_id     = local.main_zone_id

  subject_alternative_names = local.alternative_domains

  validation_method   = "DNS"
  wait_for_validation = true

  zones = local.zones_by_domain

  tags = local.tags
}

module "cdn" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "6.3.0"

  aliases             = local.all_domains
  comment             = local.main_domain
  default_root_object = "index.html"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = var.cloudfront_price_class
  web_acl_id          = var.waf_acl_arn

  custom_error_response = local.oidc_enabled ? [] : [
    {
      error_caching_min_ttl = 3000
      error_code            = 403
      response_code         = var.override_status_code_403
      response_page_path    = "/index.html"
    },
    {
      error_caching_min_ttl = 3000
      error_code            = 404
      response_code         = var.override_status_code_404
      response_page_path    = "/index.html"
    }
  ]

  default_cache_behavior = {
    allowed_methods            = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods             = ["GET", "HEAD"]
    compress                   = true
    target_origin_id           = var.s3_bucket_name
    response_headers_policy_id = local.custom_headers ? aws_cloudfront_response_headers_policy.this[0].id : null
    viewer_protocol_policy     = "redirect-to-https"
    default_ttl                = var.cache_ttl.default
    min_ttl                    = var.cache_ttl.min
    max_ttl                    = var.cache_ttl.max

    forwarded_values = {
      query_string = false
      cookies = {
        forward = local.oidc_enabled ? "all" : "none"
      }
    }

    lambda_function_association = module.oidc.lambda_edge_function_arn == null ? {} : {
      viewer-request = {
        lambda_arn   = module.oidc.lambda_edge_function_arn
        include_body = false
      }
    }

    function_association = {
      for k, arn in {
        "viewer-request"  = var.functions.viewer_request
        "viewer-response" = var.functions.viewer_response
      } : k => { function_arn = arn } if arn != null
    }
  }

  logging_config = var.logs_bucket_domain_name == null ? null : {
    bucket          = var.logs_bucket_domain_name
    prefix          = "cloudfront/access_logs/${local.main_domain_sanitized}/"
    include_cookies = false
  }

  ordered_cache_behavior = concat(
    [],
    local.oidc_enabled ? [
      {
        path_pattern             = "/callback*"
        target_origin_id         = "api-gateway-origin"
        allowed_methods          = ["GET", "HEAD", "OPTIONS"]
        cached_methods           = ["GET", "HEAD"]
        viewer_protocol_policy   = "redirect-to-https"
        compress                 = true
        cache_policy_id          = aws_cloudfront_cache_policy.oidc[0].id
        origin_request_policy_id = aws_cloudfront_origin_request_policy.oidc[0].id
      }
    ] : [],
    [
      for p in var.proxy_paths : {
        path_pattern = "${trim(p.path_prefix, "/")}/*" # safe variant: "/${trim(p.path_prefix, "/")}/*"

        allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
        cached_methods   = ["GET", "HEAD", "OPTIONS"]
        target_origin_id = p.origin_domain

        viewer_protocol_policy = "redirect-to-https"

        origin_request_policy_id = data.aws_cloudfront_origin_request_policy.managed_all_viewer_and_cloudfront_headers.id
        cache_policy_id          = data.aws_cloudfront_cache_policy.managed_caching_disabled.id
      }
    ]
  )

  origin = merge(
    {
      s3_bucket = {
        domain_name               = module.s3_bucket.s3_bucket_bucket_regional_domain_name
        origin_access_control_key = "s3"
        origin_id                 = var.s3_bucket_name
        origin_path               = var.origin_path
      }
    },
    local.oidc_enabled ? {
      oidc_callback = {
        domain_name = split("/", module.oidc.oidc_callback_url_base)[2]
        origin_id   = "api-gateway-origin"
        custom_origin_config = {
          http_port              = 80
          https_port             = 443
          origin_protocol_policy = "https-only"
          origin_ssl_protocols   = ["TLSv1.2"]
        }
      }
    } : {},
    {
      for i, p in var.proxy_paths : "proxy_${i}" => {
        domain_name = p.origin_domain
        origin_id   = p.origin_domain
        origin_path = startswith(p.path_prefix, "/") ? p.path_prefix : "/${p.path_prefix}"

        custom_origin_config = {
          http_port              = 80
          https_port             = 443
          origin_protocol_policy = "https-only"
          origin_ssl_protocols   = ["TLSv1.2", "TLSv1.1"]
        }
      }
    }
  )

  origin_access_control = {
    s3 = {
      name             = "Access from CF to S3 - ${local.main_domain}"
      description      = "Access from CF to S3 - ${local.main_domain}"
      origin_type      = "s3"
      signing_behavior = "always"
      signing_protocol = "sigv4"
    }
  }

  restrictions = {
    geo_restriction = {
      restriction_type = var.restriction_type
      locations        = var.restrictions_locations
    }
  }

  tags = local.tags

  viewer_certificate = {
    cloudfront_default_certificate = false
    acm_certificate_arn            = module.certificate.acm_certificate_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2018"
  }
}

resource "aws_cloudfront_cache_policy" "oidc" {
  count = local.oidc_enabled ? 1 : 0

  name        = "no-cache-oidc-policy_${replace(local.main_domain_sanitized, ".", "-")}"
  comment     = "Disable caching for OIDC"
  default_ttl = 0
  min_ttl     = 0
  max_ttl     = 0

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }

    headers_config {
      header_behavior = "none"
    }

    query_strings_config {
      query_string_behavior = "none"
    }

    #enable_accept_encoding_gzip = true
  }
}

resource "aws_cloudfront_origin_request_policy" "oidc" {
  count = local.oidc_enabled ? 1 : 0

  name    = "oidc-origin-policy_${replace(local.main_domain_sanitized, ".", "-")}"
  comment = "Forward all cookies and query strings for OIDC"

  cookies_config {
    cookie_behavior = "all"
  }

  headers_config {
    header_behavior = "none"
  }

  query_strings_config {
    query_string_behavior = "all"
  }
}

resource "aws_route53_record" "this" {
  for_each = local.zones_by_domain

  zone_id = each.value
  name    = each.key
  type    = "A"

  alias {
    name                   = module.cdn.cloudfront_distribution_domain_name
    zone_id                = module.cdn.cloudfront_distribution_hosted_zone_id
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

  dynamic "security_headers_config" {
    for_each = local.security_headers ? [1] : []
    content {
      dynamic "content_security_policy" {
        for_each = var.custom_headers.content_security_policy != null ? [1] : []
        content {
          content_security_policy = var.custom_headers.content_security_policy.policy
          override                = var.custom_headers.content_security_policy.override
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
  }

  dynamic "custom_headers_config" {
    for_each = var.custom_headers.headers != null && var.custom_headers.headers != {} ? [1] : []
    content {
      dynamic "items" {
        for_each = var.custom_headers.headers != null ? var.custom_headers.headers : {}
        content {
          header   = items.key
          value    = items.value.value
          override = items.value.override
        }
      }
    }
  }

}
