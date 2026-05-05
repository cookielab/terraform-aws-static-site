module "oidc" {
  source = "./modules/oidc"

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  oidc               = var.oidc
  application_domain = local.main_domain
  project_name       = replace(local.main_domain_sanitized, ".", "-")

  edge_lambda_zip_path     = var.edge_lambda_zip_path
  callback_lambda_zip_path = var.callback_lambda_zip_path

  tags = local.tags
}
