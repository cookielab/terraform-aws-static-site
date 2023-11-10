resource "aws_iam_user" "deploy" {
  name = "zvirt-${local.main_domain_sanitized}-deploy"
}

resource "aws_iam_access_key" "deploy" {
  user = aws_iam_user.deploy.name
}

data "aws_iam_policy_document" "deploy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:DeleteObject",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject"
    ]
    resources = [module.s3_bucket.s3_bucket_arn, "${module.s3_bucket.s3_bucket_arn}/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "cloudfront:CreateInvalidation",
      "cloudfront:ListInvalidations",
      "cloudfront:GetInvalidation"
    ]
    resources = [aws_cloudfront_distribution.this.arn]
  }
}

resource "aws_iam_user_policy" "deploy" {
  user = aws_iam_user.deploy.name

  policy = data.aws_iam_policy_document.deploy.json
}

module "gitlab" {
  count = var.gitlab_project_id == null ? 0 : 1

  source = "./modules/gitlab"

  gitlab_project_id  = var.gitlab_project_id
  gitlab_environment = var.gitlab_environment

  aws_s3_bucket_name             = module.s3_bucket.s3_bucket_id
  aws_cloudfront_distribution_id = aws_cloudfront_distribution.this.id
  aws_access_key_id              = aws_iam_access_key.deploy.id
  aws_secret_access_key          = aws_iam_access_key.deploy.secret
  aws_default_region             = data.aws_region.current.name
}

moved {
  from = gitlab_project_variable.s3_bucket[0]
  to   = module.gitlab[0].gitlab_project_variable.s3_bucket
}

moved {
  from = gitlab_project_variable.cloudfront_distribution_id[0]
  to   = module.gitlab[0].gitlab_project_variable.cloudfront_distribution_id
}

moved {
  from = gitlab_project_variable.site_aws_access_key_id[0]
  to   = module.gitlab[0].gitlab_project_variable.site_aws_access_key_id
}

moved {
  from = gitlab_project_variable.site_aws_secret_access_key[0]
  to   = module.gitlab[0].gitlab_project_variable.site_aws_secret_access_key
}
