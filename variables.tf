variable "domain_zone_id" {
  type        = string
  description = "The ID of the hosted zone for domain"
}

variable "domains" {
  type        = list(string)
  description = "List of domain aliases. You can also specify wildcard eg.: `*.example.com`"
  validation {
    condition     = length(var.domains) >= 1
    error_message = "The domains value must contain at least one domain."
  }
}

variable "s3_bucket_name" {
  type = string
}

variable "s3_bucket_policy" {
  type        = string
  default     = "{}"
  description = "Additional S3 bucket policy"
}

variable "gitlab_project_ids" {
  description = "Integrates with GitLab CI/CD to deploy site and invalidate CloudFront cache"
  type        = list(string)
  default     = []
}

variable "gitlab_project_id" {
  type        = string
  description = "Deprecated: Use gitlab_project_ids instead"
  default     = ""
}

variable "gitlab_environment" {
  description = "GitLab environment name"
  type        = string
  default     = "*"
}

variable "logs_bucket" {
  description = "Bucket to store CloudFront logs"
  type        = string
  default     = null
}

variable "logs_bucket_domain_name" {
  type    = string
  default = null
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
  type    = map(string)
  default = {}
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
  type = list(object({
    origin_domain = string
    path_prefix   = string
  }))
  default = []
}

variable "functions" {
  type = object({
    viewer_request  = optional(string)
    viewer_response = optional(string)
  })
  default = {}
}

variable "enable_deploy_role" {
  type        = bool
  default     = false
  description = "Toggle IAM role creation for S3 deploy & CloudFront invalidation; This requires existing aws_iam_openid_connect_provider matching domain of your gitlab provider"
}

variable "enable_deploy_user" {
  type        = bool
  default     = true
  description = "Toggle s3 deploy user creation"
}

variable "encrypt_with_kms" {
  type        = bool
  default     = false
  description = "Enable server side s3 bucket encryption with KMS key"
}

variable "kms_deletion_window_in_days" {
  type        = number
  default     = 30
  description = "The waiting period, specified in number of days. After the waiting period ends, AWS KMS deletes the KMS key"
}

variable "kms_key_policy" {
  type        = string
  default     = "{}"
  description = "Additional KSM key policy"
}

variable "origin_path" {
  type        = string
  default     = ""
  description = "Cloudfront origin path"
}

variable "min_ttl" {
  description = "Minimum amount of time that you want objects to stay in a CloudFront cache"
  type        = number
  default     = 0
}

variable "default_ttl" {
  description = "Default amount of time that you want objects to stay in a CloudFront cache"
  type        = number
  default     = 3600
}

variable "max_ttl" {
  description = "Maximum amount of time that you want objects to stay in a CloudFront cache"
  type        = number
  default     = 86400
}

variable "aws_env_vars_suffix" {
  description = "Append suffix for Gitlab CI/CD environment variables if needed"
  type        = string
  default     = ""
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
  type    = bool
  default = false
}

variable "response_header_access_control_allow_credentials" {
  type    = bool
  default = false
}

variable "extra_domains" {
  type        = map(string)
  description = "Map of extra_domains with domain name and zone_id"
  default     = {}
}

variable "custom_headers" {
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
  type = list(object({
    protected = optional(bool, false)
    masked    = optional(bool, false)
    raw       = optional(bool, true)
    key       = string
    value     = string
  }))
  default     = []
  description = "List of additional gitlab CI/CD variables"
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
