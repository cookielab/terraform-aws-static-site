variable "gitlab_project_ids" {
  type = list(string)
}

variable "gitlab_environment" {
  type    = string
  default = "*"
}

variable "aws_s3_bucket_name" {
  type = string
}

variable "aws_cloudfront_distribution_id" {
  type = string
}

variable "aws_role_arn" {
  type = string
}

variable "aws_access_key_id" {
  type = string
}

variable "enable_deploy_role" {
  type = bool
}

variable "enable_deploy_user" {
  type = bool
}

variable "aws_secret_access_key" {
  type      = string
  sensitive = true
}

variable "aws_default_region" {
  type = string
}

variable "aws_env_vars_suffix" {
  type    = string
  default = ""
}

variable "extra_gitlab_cicd_variables" {
  type = list(object({
    protected = optional(bool, false)
    masked    = optional(bool, false)
    raw       = optional(bool, true)
    key       = string
    value     = string
  }))
  default = []
}
