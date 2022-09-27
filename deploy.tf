resource "aws_iam_user" "deploy" {
  name = "zvirt-${var.domain}-deploy"
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

resource "gitlab_project_variable" "s3_bucket" {
  count = var.gitlab_project_id != null ? 1 : 0

  project = var.gitlab_project_id

  protected = false
  masked    = false

  key   = "AWS_S3_BUCKET"
  value = module.s3_bucket.s3_bucket_id

  environment_scope = var.gitlab_environment != null ? var.gitlab_environment : var.domain
}

resource "gitlab_project_variable" "cloudfront_distribution_id" {
  count = var.gitlab_project_id != null ? 1 : 0

  project = var.gitlab_project_id

  protected = false
  masked    = false

  key   = "AWS_CF_DISTRIBUTION_ID"
  value = aws_cloudfront_distribution.this.id

  environment_scope = var.gitlab_environment != null ? var.gitlab_environment : var.domain
}

resource "gitlab_project_variable" "site_aws_access_key_id" {
  count = var.gitlab_project_id != null ? 1 : 0

  project = var.gitlab_project_id

  protected = false
  masked    = false

  key   = "AWS_ACCESS_KEY_ID"
  value = aws_iam_access_key.deploy.id

  environment_scope = var.gitlab_environment != null ? var.gitlab_environment : var.domain
}

resource "gitlab_project_variable" "site_aws_secret_access_key" {
  count = var.gitlab_project_id != null ? 1 : 0

  project = var.gitlab_project_id

  protected = false
  masked    = true

  key   = "AWS_SECRET_ACCESS_KEY"
  value = aws_iam_access_key.deploy.secret

  environment_scope = var.gitlab_environment != null ? var.gitlab_environment : var.domain
}
