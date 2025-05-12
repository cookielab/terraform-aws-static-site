locals {
  cicd_variable_flat_list = flatten([
    for project_id in var.gitlab_project_ids : [
      for variable in var.extra_gitlab_cicd_variables : {
        key        = "${project_id}-${variable.key}"
        project_id = project_id
        variable   = variable
      }
    ]
  ])

  cicd_variable_flat_map = {
    for item in local.cicd_variable_flat_list :
    item.key => merge(item.variable, { project_id = item.project_id })
  }
}

data "gitlab_project" "this" {
  for_each = toset(var.gitlab_project_ids)
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

resource "gitlab_project_variable" "site_aws_role_arn" {
  for_each = var.enable_deploy_role ? data.gitlab_project.this : {}

  project = each.value.id

  protected = false
  masked    = false
  raw       = true

  key   = "AWS_ROLE_ARN${var.aws_env_vars_suffix}"
  value = var.aws_role_arn

  environment_scope = var.gitlab_environment
}

resource "gitlab_project_variable" "site_aws_access_key_id" {
  for_each = var.enable_deploy_user ? data.gitlab_project.this : {}

  project = each.value.id

  protected = false
  masked    = false
  raw       = true

  key   = "AWS_ACCESS_KEY_ID${var.aws_env_vars_suffix}"
  value = var.aws_access_key_id

  environment_scope = var.gitlab_environment
}

resource "gitlab_project_variable" "site_aws_secret_access_key" {
  for_each = var.enable_deploy_user ? data.gitlab_project.this : {}

  project = each.value.id

  protected = false
  masked    = true
  raw       = true

  key   = "AWS_SECRET_ACCESS_KEY${var.aws_env_vars_suffix}"
  value = var.aws_secret_access_key

  environment_scope = var.gitlab_environment
}

resource "gitlab_project_variable" "extra" {
  for_each = local.cicd_variable_flat_map

  project = each.value.project_id

  protected = each.value.protected
  masked    = each.value.masked
  raw       = each.value.raw

  key   = each.value.key
  value = each.value.value

  environment_scope = var.gitlab_environment
}
