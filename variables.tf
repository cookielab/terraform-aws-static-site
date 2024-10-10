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

variable "gitlab_project_id" {
  description = "Integrates with GitLab CI/CD to deploy site and invalidate CloudFront cache"
  type        = string
  default     = null
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

variable "s3_cors_enabled" {
  description = "Enable or disable CORS configuration for the S3 bucket"
  type        = bool
  default     = false
}

variable "s3_cors_rules" {
  description = "List of CORS rules for the S3 bucket"
  type = list(object({
    allowed_headers = list(string)
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = optional(list(string))
    max_age_seconds = optional(number)
  }))
}
