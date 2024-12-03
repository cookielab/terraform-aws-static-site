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

variable "aws_access_key_id" {
  type = string
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
