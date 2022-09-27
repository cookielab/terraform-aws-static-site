variable "domain_zone_id" {
  type        = string
  description = "The ID of the hosted zone for domain"
}

variable "domain" {
  type = string
}

variable "wildcard" {
  type        = bool
  default     = false
  description = "Add support for wildcard domain"
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

variable "cloudfront_price_class" {
  type    = string
  default = "PriceClass_100"
}

variable "tags" {
  type    = map(string)
  default = {}
}
