variable "identity_base_name" {
  description = "The base name for the IAM user/role withtout `zvirt-` prefix and `-deploy` suffix"
  type        = string
}

variable "s3_bucket_arn" {
  description = "The ARN for the S3 bucket hosting the website for the IAM user/role policy"
  type        = string
}

variable "cloudfront_distribution_arn" {
  description = "CloudFront distribution ID for the IAM user/role policy"
  type        = string
}

variable "gitlab_project_ids" {
  description = "Integrates with GitLab CI/CD to deploy site and invalidate CloudFront cache"
  type        = list(string)
  default     = []
}

variable "enable_deploy_role" {
  description = "Toggle IAM role creation for S3 deploy & CloudFront invalidation; This requires existing `aws_iam_openid_connect_provider` matching domain of your gitlab provider."
  type        = bool
  default     = false
}

variable "enable_deploy_user" {
  description = "Toggle s3 deploy user creation for S3 deploy & Cloudfront invalidation"
  type        = bool
  default     = true
}


variable "tags" {
  description = "Map of tags to be set on resources"
  type        = map(string)
  default     = {}
}
