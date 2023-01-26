variable "gitlab_project_id" {
  type = string
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
