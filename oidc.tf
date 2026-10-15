module "oidc" {
  source = "./modules/oidc"

  oidc               = var.oidc
  application_domain = local.main_domain
  project_name       = replace(local.main_domain_sanitized, ".", "-")

  edge_lambda_zip_path     = var.oidc_edge_lambda_zip_path
  callback_lambda_zip_path = var.oidc_callback_lambda_zip_path

  tags = local.tags
}
