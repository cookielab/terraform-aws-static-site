locals {
  gitlab_project_ids = toset(concat(var.gitlab_project_ids, var.gitlab_project_id != "" ? [var.gitlab_project_id] : []))
}

resource "aws_iam_user" "deploy" {
  count = var.enable_deploy_user == true ? 1 : 0
  name  = "zvirt-${local.main_domain_sanitized}-deploy"
}

resource "aws_iam_access_key" "deploy" {
  count = var.enable_deploy_user == true ? 1 : 0
  user  = aws_iam_user.deploy[0].name
}

data "aws_iam_policy_document" "deploy" {
  count = var.enable_deploy_user == true ? 1 : 0
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
  count = var.enable_deploy_user == true ? 1 : 0

  user = aws_iam_user.deploy[0].name

  policy = data.aws_iam_policy_document.deploy[0].json
}

module "gitlab" {
  count = length(local.gitlab_project_ids) == 0 ? 0 : 1

  source = "./modules/gitlab"

  gitlab_project_ids = local.gitlab_project_ids
  gitlab_environment = var.gitlab_environment

  aws_s3_bucket_name             = module.s3_bucket.s3_bucket_id
  aws_cloudfront_distribution_id = aws_cloudfront_distribution.this.id
  aws_access_key_id              = aws_iam_access_key.deploy[0].id
  aws_secret_access_key          = aws_iam_access_key.deploy[0].secret
  aws_default_region             = data.aws_region.current.name
  aws_env_vars_suffix            = var.aws_env_vars_suffix
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

moved {
  from = aws_iam_access_key.deploy
  to   = aws_iam_access_key.deploy[0]
}

moved {
  from = aws_iam_access_key.deploy
  to   = aws_iam_access_key.deploy[0]
}

moved {
  from = aws_iam_user.deploy
  to   = aws_iam_user.deploy[0]
}
