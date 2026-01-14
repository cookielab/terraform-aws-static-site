locals {
  first_project_web_url = length(var.gitlab_project_ids) > 0 ? data.gitlab_project.this[element(keys(data.gitlab_project.this), 0)].web_url : ""
  gitlab_domain         = length(var.gitlab_project_ids) > 0 ? regex("https://([^/]+)/.*", local.first_project_web_url)[0] : ""
}

data "gitlab_project" "this" {
  for_each = toset(var.gitlab_project_ids)
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
      values   = [for repo in var.gitlab_project_ids : format("project_path:%s:ref_type:*:ref:*", data.gitlab_project.this[repo].path_with_namespace)]
      variable = format("%s:sub", local.gitlab_domain)
    }

    principals {
      identifiers = [data.aws_iam_openid_connect_provider.gitlab[0].arn]
      type        = "Federated"
    }
  }
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
    resources = [
      var.s3_bucket_arn,
      "${var.s3_bucket_arn}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "cloudfront:CreateInvalidation",
      "cloudfront:ListInvalidations",
      "cloudfront:GetInvalidation"
    ]
    resources = [var.cloudfront_distribution_arn]
  }
}

resource "aws_iam_role" "deploy" {
  count              = var.enable_deploy_role ? 1 : 0
  assume_role_policy = data.aws_iam_policy_document.assume_role[0].json
  name               = "zvirt-${var.identity_base_name}-deploy"
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
  name  = "zvirt-${var.identity_base_name}-deploy"
  tags  = var.tags
}

resource "aws_iam_access_key" "deploy" {
  count = var.enable_deploy_user ? 1 : 0
  user  = aws_iam_user.deploy[0].name
}

resource "aws_iam_user_policy" "deploy" {
  count = var.enable_deploy_user ? 1 : 0

  user   = aws_iam_user.deploy[0].name
  policy = data.aws_iam_policy_document.deploy[0].json
}
