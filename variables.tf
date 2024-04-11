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

variable "gitlab_project_id" {
  type    = string
  default = null
}

variable "gitlab_environment" {
  type    = string
  default = "*"
}

variable "logs_bucket" {
  type    = string
  default = null
}

variable "logs_bucket_domain_name" {
  type    = string
  default = null
}

variable "cloudfront_price_class" {
  type    = string
  default = "PriceClass_100"
}

variable "override_status_code_404" {
  type    = number
  default = 200
}

variable "override_status_code_403" {
  type    = number
  default = 403
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
