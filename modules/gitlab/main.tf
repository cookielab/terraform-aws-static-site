data "gitlab_project" "this" {
  id = var.gitlab_project_id
}

resource "gitlab_project_variable" "s3_bucket" {
  project = data.gitlab_project.this.id

  protected = false
  masked    = false

  key   = "AWS_S3_BUCKET"
  value = var.aws_s3_bucket_name

  environment_scope = var.gitlab_environment
}

resource "gitlab_project_variable" "cloudfront_distribution_id" {
  project = data.gitlab_project.this.id

  protected = false
  masked    = false

  key   = "AWS_CF_DISTRIBUTION_ID"
  value = var.aws_cloudfront_distribution_id

  environment_scope = var.gitlab_environment
}

resource "gitlab_project_variable" "site_aws_access_key_id" {
  project = data.gitlab_project.this.id

  protected = false
  masked    = false

  key   = "AWS_ACCESS_KEY_ID"
  value = var.aws_access_key_id

  environment_scope = var.gitlab_environment
}

resource "gitlab_project_variable" "site_aws_secret_access_key" {
  project = data.gitlab_project.this.id

  protected = false
  masked    = true

  key   = "AWS_SECRET_ACCESS_KEY"
  value = var.aws_secret_access_key

  environment_scope = var.gitlab_environment
}
