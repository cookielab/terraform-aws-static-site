variable "domain_zone_id" { # Deprecated; to be removed in upcomming releases
  description = "Deprecated!  Use `zones_and_domains`.The ID of the hosted zone for domain"
  type        = string
  default     = null
  validation {
    condition     = (var.domain_zone_id == null)
    error_message = "The domain_zone_id input is deprecated, Please use zones_and_domains instead."
  }
}

variable "domains" { # Deprecated; to be removed in upcomming releases
  description = "Deprecated! Use `zones_and_domains`. List of domain aliases. You can also specify wildcard eg.: `*.example.com`"
  type        = list(string)
  default     = []
  validation {
    condition     = (length(var.domains) == 0)
    error_message = "The domain input is deprecated, Please use zones_and_domains instead."
  }
}

variable "extra_domains" { # Deprecated; to be removed in upcomming releases
  description = "Deprecated! Use `zones_and_domains`. Map of extra_domains with domain name and zone_id; This input can be kept initialy for moved blocks generaiton"
  type        = map(string)
  default     = {}
  validation {
    condition     = (length(var.extra_domains) == 0)
    error_message = "The extra_domains input is deprecated, Please use zones_and_domains instead."
  }
}

variable "zones_and_domains" {
  description = "Ordered list of Route53 with zone_id list of domain aliases. The first item is used as the main domain."
  type = list(object({
    zone_id = string
    domains = list(string)
  }))

  validation {
    condition = (
      length(var.zones_and_domains) >= 1
      &&
      alltrue([
        for z in var.zones_and_domains :
        length(trimspace(z.zone_id)) > 0
        && length(z.domains) >= 1
        && alltrue([for d in z.domains : length(trimspace(d)) > 0])
      ])
    )
    error_message = "zones_and_domains must contain at least 1 zone, each zone_id must be non-empty, and each zone must have at least 1 non-empty domain."
  }
}

variable "s3_bucket_name" {
  description = "The name for the S3 bucket hosting the website"
  type        = string
}

variable "s3_bucket_policy" {
  description = "Additional S3 bucket policy"
  type        = string
  default     = "{}"
}

variable "logs_bucket" {
  description = "Bucket to store CloudFront logs"
  type        = string
  default     = null
}

variable "logs_bucket_domain_name" {
  description = "Bucket to store CloudFront logs"
  type        = string
  default     = null
}

variable "gitlab_aws_env_vars_suffix" {
  description = "Append suffix for Gitlab CI/CD environment variables if needed"
  type        = string
  default     = ""
}

variable "gitlab_project_ids" {
  description = "Integrates with GitLab CI/CD to deploy site and invalidate CloudFront cache"
  type        = list(string)
  default     = []
}

variable "gitlab_environment" {
  description = "GitLab environment name"
  type        = string
  default     = "*"
}

variable "cloudfront_price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_100"
}

variable "override_status_code_404" {
  description = "Override status code for 404 error"
  type        = number
  default     = 200
}

variable "override_status_code_403" {
  description = "Override status code for 403 error"
  type        = number
  default     = 403
}

variable "tags" {
  description = "Map of tags to be set on resources"
  type        = map(string)
  default     = {}
}

variable "waf_acl_arn" {
  description = "WAF ACL ARN"
  type        = string
  default     = null
}

variable "restriction_type" {
  description = "Apply for geo restrictions, values: none, whitelist, blacklist"
  type        = string
  default     = "none"
}

variable "restrictions_locations" {
  description = "List of country codes"
  type        = list(string)
  default     = null
}

variable "proxy_paths" {
  description = "Configure CloudFront to forward specific URL path prefixes (e.g. /api, /auth) to different backend origins instead of the default origin."
  type = list(object({
    origin_domain = string
    path_prefix   = string
  }))
  default = []
}

variable "functions" {
  description = "CloudFront Functions ARN to run on incoming requests and/or outgoing responses (viewer-request / viewer-response) for the default cache behavior."
  type = object({
    viewer_request  = optional(string)
    viewer_response = optional(string)
  })
  default = {}
}

variable "enable_deploy_role" {
  description = "Toggle IAM role creation for S3 deploy & CloudFront invalidation; This requires existing aws_iam_openid_connect_provider matching domain of your gitlab provider"
  type        = bool
  default     = false
}

variable "enable_deploy_user" {
  description = "Toggle s3 deploy user creation"
  type        = bool
  default     = true
}

variable "encrypt_with_kms" {
  description = "Enable server side s3 bucket encryption with KMS key"
  type        = bool
  default     = false
}

variable "kms_deletion_window_in_days" {
  description = "The waiting period, specified in number of days. After the waiting period ends, AWS KMS deletes the KMS key"
  type        = number
  default     = 30
}

variable "kms_key_policy" {
  description = "Additional KSM key policy"
  type        = string
  default     = "{}"
}

variable "origin_path" {
  description = "Cloudfront origin path"
  type        = string
  default     = ""
}

variable "cache_ttl" {
  description = "Cache TTLs configuration for CloudFront distribition; sets minimum/maximum and default amount of time the objects stays in cache"
  type = object({
    min     = optional(number, 0)
    max     = optional(number, 86400)
    default = optional(number, 3600)
  })
  default = {}
}

variable "s3_cors_rule" {
  description = "List of maps containing rules for Cross-Origin Resource Sharing."
  type = list(object({
    allowed_headers = optional(list(string))
    allowed_methods = optional(list(string))
    allowed_origins = optional(list(string))
    expose_headers  = optional(list(string))
    max_age_seconds = optional(number)
  }))
  default = []
}

variable "response_header_origin_override" {
  description = "If enabled, CloudFront will replace headers returned by the origin (such as CORS or security headers) with values defined in the response headers policy."
  type        = bool
  default     = false
}

variable "response_header_access_control_allow_credentials" {
  description = "A Boolean value that CloudFront uses as the value for the Access-Control-Allow-Credentials HTTP response header."
  type        = bool
  default     = false
}

variable "custom_headers" {
  description = "CloudFront response headers configuration (custom headers, CORS, and security headers) with optional origin override behavior."
  type = object({
    headers = optional(map(object({
      override = optional(bool, true)
      value    = string
    })))
    cors_rules = optional(object({
      use             = optional(bool, false)
      allowed_headers = optional(list(string))
      allowed_methods = optional(list(string))
      allowed_origins = optional(list(string))
      expose_headers  = optional(list(string))
      max_age_seconds = optional(number)
      override        = optional(bool, true)
    }), null)
    frame_options = optional(object({
      use          = optional(bool, false)
      frame_option = string
      override     = optional(bool, true)
    }), null)
    referrer_policy = optional(object({
      use             = optional(bool, false)
      referrer_policy = string
      override        = optional(bool, true)
    }), null)
    xss_protection = optional(object({
      use        = optional(bool, false)
      mode_block = bool
      protection = bool
      override   = optional(bool, true)
    }), null)
    content_security_policy = optional(object({
      use      = optional(bool, false)
      policy   = string
      override = optional(bool, true)
    }), null)
    strict_transport_security = optional(object({
      use                        = optional(bool, false)
      access_control_max_age_sec = string
      include_subdomains         = bool
      preload                    = bool
      override                   = optional(bool, true)
    }), null)
    content_type_options = optional(object({
      override = optional(bool, true)
    }), null)
  })
  default = null
}

variable "extra_gitlab_cicd_variables" {
  description = "List of additional gitlab CI/CD variables"
  type = list(object({
    protected = optional(bool, false)
    masked    = optional(bool, false)
    raw       = optional(bool, true)
    key       = string
    value     = string
  }))
  default = []
}

variable "oidc" {
  description = "List of OIDC providers"
  type = list(object({
    application_name = string
    application_id   = string
    client_secret    = string
    auth_url         = string
    token_url        = string
    session_druation = optional(number, 12 * 3600)
  }))
  default = []
}
