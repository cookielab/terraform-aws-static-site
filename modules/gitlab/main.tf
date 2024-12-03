locals {
  gitlab_project_ids = toset(concat(var.gitlab_project_ids, var.gitlab_project_id != null ? [var.gitlab_project_id] : []))
}

data "gitlab_project" "this" {
  for_each = local.gitlab_project_ids
  id       = each.value
}

resource "gitlab_project_variable" "s3_bucket" {
  for_each = data.gitlab_project.this

  project = each.value.id

  protected = false
  masked    = false
  raw       = true

  key   = "AWS_S3_BUCKET${var.aws_env_vars_suffix}"
  value = var.aws_s3_bucket_name

  environment_scope = var.gitlab_environment
}

resource "gitlab_project_variable" "aws_default_region" {
  for_each = data.gitlab_project.this

  project = each.value.id

  protected = false
  masked    = false
  raw       = true

  key   = "AWS_DEFAULT_REGION${var.aws_env_vars_suffix}"
  value = var.aws_default_region

  environment_scope = var.gitlab_environment
}

resource "gitlab_project_variable" "cloudfront_distribution_id" {
  for_each = data.gitlab_project.this

  project = each.value.id

  protected = false
  masked    = false
  raw       = true

  key   = "AWS_CF_DISTRIBUTION_ID${var.aws_env_vars_suffix}"
  value = var.aws_cloudfront_distribution_id

  environment_scope = var.gitlab_environment
}

resource "gitlab_project_variable" "site_aws_access_key_id" {
  for_each = data.gitlab_project.this

  project = each.value.id

  protected = false
  masked    = false
  raw       = true

  key   = "AWS_ACCESS_KEY_ID${var.aws_env_vars_suffix}"
  value = var.aws_access_key_id

  environment_scope = var.gitlab_environment
}

resource "gitlab_project_variable" "site_aws_secret_access_key" {
  for_each = data.gitlab_project.this

  project = each.value.id

  protected = false
  masked    = true
  raw       = true

  key   = "AWS_SECRET_ACCESS_KEY${var.aws_env_vars_suffix}"
  value = var.aws_secret_access_key

  environment_scope = var.gitlab_environment
}
