module "gitlab" {
  count = length(var.gitlab_project_ids) == 0 ? 0 : 1

  source = "./modules/gitlab"

  project_ids = var.gitlab_project_ids

  cicd_variables = concat(
    [
      {
        key               = "AWS_S3_BUCKET${var.gitlab_aws_env_vars_suffix}"
        value             = module.s3_bucket.s3_bucket_id
        environment_scope = var.gitlab_environment
      },
      {
        key               = "AWS_DEFAULT_REGION${var.gitlab_aws_env_vars_suffix}"
        value             = data.aws_region.current.region
        environment_scope = var.gitlab_environment
      },
      {
        key               = "AWS_CF_DISTRIBUTION_ID${var.gitlab_aws_env_vars_suffix}"
        value             = module.cdn.cloudfront_distribution_id
        environment_scope = var.gitlab_environment
      },
    ],
    var.enable_deploy_role ? [
      {
        key               = "AWS_ROLE_ARN${var.gitlab_aws_env_vars_suffix}"
        value             = module.deploy_identity.deploy_role_arn
        environment_scope = var.gitlab_environment
      }
    ] : [],
    var.enable_deploy_user ? [
      {
        key               = "AWS_ACCESS_KEY_ID${var.gitlab_aws_env_vars_suffix}"
        value             = module.deploy_identity.aws_access_key_id
        environment_scope = var.gitlab_environment
      },
      {
        key               = "AWS_SECRET_ACCESS_KEY${var.gitlab_aws_env_vars_suffix}"
        value             = module.deploy_identity.aws_secret_access_key
        masked            = true
        environment_scope = var.gitlab_environment
      },
    ] : [],
    var.extra_gitlab_cicd_variables
  )
}
