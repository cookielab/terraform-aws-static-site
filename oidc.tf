module "oidc" {
  source = "./modules/oidc"

  oidc               = var.oidc
  application_domain = local.main_domain
  project_name       = replace(local.main_domain_sanitized, ".", "-")
  tags               = local.tags
}
