locals {
  gitlab_project_ids    = toset(concat(var.gitlab_project_ids, var.gitlab_project_id != "" ? [var.gitlab_project_id] : []))
  first_project_web_url = length(local.gitlab_project_ids) > 0 ? data.gitlab_project.this[element(keys(data.gitlab_project.this), 0)].web_url : ""
  gitlab_domain         = length(local.gitlab_project_ids) > 0 ? regex("https://([^/]+)/.*", local.first_project_web_url)[0] : ""
}

data "gitlab_project" "this" {
  for_each = local.gitlab_project_ids
  id       = each.value
}

data "aws_iam_openid_connect_provider" "gitlab" {
  count = var.enable_deploy_role ? 1 : 0
  url   = format("https://%s", local.gitlab_domain)
}

data "aws_iam_policy_document" "assume_role" {
  count = var.enable_deploy_role ? 1 : 0
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "ForAnyValue:StringLike"
      values   = [for repo in local.gitlab_project_ids : format("project_path:%s:ref_type:*:ref:*", data.gitlab_project.this[repo].path_with_namespace)]
      variable = format("%s:sub", local.gitlab_domain)
    }

    principals {
      identifiers = [data.aws_iam_openid_connect_provider.gitlab[0].arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "deploy" {
  count              = var.enable_deploy_role ? 1 : 0
  assume_role_policy = data.aws_iam_policy_document.assume_role[0].json
  name               = "zvirt-${local.main_domain_sanitized}-deploy"
  tags               = var.tags
}

resource "aws_iam_role_policy" "deploy" {
  count  = var.enable_deploy_role ? 1 : 0
  name   = "S3Deploy-CFInvalidate"
  role   = aws_iam_role.deploy[0].id
  policy = data.aws_iam_policy_document.deploy[0].json
}

resource "aws_iam_user" "deploy" {
  count = var.enable_deploy_user ? 1 : 0
  name  = "zvirt-${local.main_domain_sanitized}-deploy"
}

resource "aws_iam_access_key" "deploy" {
  count = var.enable_deploy_user ? 1 : 0
  user  = aws_iam_user.deploy[0].name
}

data "aws_iam_policy_document" "deploy" {
  count = var.enable_deploy_user || var.enable_deploy_role ? 1 : 0
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
  count = var.enable_deploy_user ? 1 : 0

  user = aws_iam_user.deploy[0].name

  policy = data.aws_iam_policy_document.deploy[0].json
}

module "gitlab" {
  count = length(local.gitlab_project_ids) == 0 ? 0 : 1

  source = "./modules/gitlab"

  gitlab_project_ids = local.gitlab_project_ids
  gitlab_environment = var.gitlab_environment

  enable_deploy_role             = var.enable_deploy_role
  enable_deploy_user             = var.enable_deploy_user
  aws_s3_bucket_name             = module.s3_bucket.s3_bucket_id
  aws_cloudfront_distribution_id = aws_cloudfront_distribution.this.id
  aws_role_arn                   = var.enable_deploy_role ? aws_iam_role.deploy[0].arn : null
  aws_access_key_id              = var.enable_deploy_user ? aws_iam_access_key.deploy[0].id : null
  aws_secret_access_key          = var.enable_deploy_user ? aws_iam_access_key.deploy[0].secret : null
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
