module "deploy_identity" {
  source = "./modules/deploy_identity"

  identity_base_name          = local.main_domain_sanitized
  enable_deploy_user          = var.enable_deploy_user
  enable_deploy_role          = var.enable_deploy_role
  s3_bucket_arn               = module.s3_bucket.s3_bucket_arn
  cloudfront_distribution_arn = module.cdn.cloudfront_distribution_arn
  gitlab_project_ids          = var.gitlab_project_ids
  tags                        = var.tags
}
