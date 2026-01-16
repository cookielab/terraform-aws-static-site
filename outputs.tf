output "aws_s3_bucket_name" {
  description = "S3 bucket name with the static site assets"
  value       = module.s3_bucket.s3_bucket_id
}

output "aws_s3_bucket_arn" {
  description = "ARN of the S3 bucket with the static site assets"
  value       = module.s3_bucket.s3_bucket_arn
}

output "aws_s3_bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket with the static site assets"
  value       = module.s3_bucket.s3_bucket_bucket_regional_domain_name
}

output "aws_cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.cdn.cloudfront_distribution_id
}

output "aws_access_key_id" {
  description = "AWS_ACCESS_KEY_ID of the deploy user"
  value       = var.enable_deploy_user ? module.deploy_identity.aws_access_key_id : null
}

output "aws_secret_access_key" {
  description = "AWS_SECRET_ACCESS_KEY of the deploy user"
  value       = var.enable_deploy_user ? module.deploy_identity.aws_secret_access_key : null
  sensitive   = true
}

output "deploy_role_arn" {
  description = "IAM Role ARN of the deploy role"
  value       = var.enable_deploy_role ? module.deploy_identity.deploy_role_arn : null
}

output "s3_kms_key_arn" {
  description = "ARN of the KMS key used for the encryption of the objects in the S3 bucket with the static site assets"
  value       = var.encrypt_with_kms ? aws_kms_key.this[0].arn : null
}

output "oidc_callback_url" {
  description = "OIDC callback URL for Redirect URI in the OIDC application"
  value       = module.oidc.oidc_callback_url_base != null ? module.oidc.oidc_callback_url_base : null
}

output "moved_blocks" { # Temporary output
  description = "Generated moved blocks for the `gitlab_project_variables` and `aws_route53_record`"
  value = "Run following output through `sed 's/PLACEHOLDER/YOUR_MODULE_NAME/'` to generate moved blocks\n\n${join("",
    [
      for d in flatten([
        for i, z in var.zones_and_domains : z.domains if i > 0
      ]) :
      <<EOF
moved {
  from = module.PLACEHOLDER.aws_route53_record.extra["${d}"]
  to   = module.PLACEHOLDER.aws_route53_record.this["${d}"]
}
EOF
    ]
    )}${join("", flatten([
      for p in var.gitlab_project_ids : [
        for v in var.extra_gitlab_cicd_variables : <<EOF
moved {
  from = module.PLACEHOLDER.module.gitlab[0].gitlab_project_variable.extra["${p}-${v.key}"]
  to   = module.PLACEHOLDER.module.gitlab[0].gitlab_project_variable.this["${p}-${v.key}"]
}
EOF
      ]
      ]))}${join("", flatten([
      for p in var.gitlab_project_ids : [
        <<EOF
moved {
  from = module.PLACEHOLDER.module.gitlab[0].gitlab_project_variable.cloudfront_distribution_id["${p}"]
  to   = module.PLACEHOLDER.module.gitlab[0].gitlab_project_variable.this["${p}-AWS_CF_DISTRIBUTION_ID"]
}
EOF
        ,
        <<EOF
moved {
  from = module.PLACEHOLDER.module.gitlab[0].gitlab_project_variable.aws_default_region["${p}"]
  to   = module.PLACEHOLDER.module.gitlab[0].gitlab_project_variable.this["${p}-AWS_DEFAULT_REGION"]
}
EOF
        ,
        <<EOF
moved {
  from = module.PLACEHOLDER.module.gitlab[0].gitlab_project_variable.s3_bucket["${p}"]
  to   = module.PLACEHOLDER.module.gitlab[0].gitlab_project_variable.this["${p}-AWS_S3_BUCKET"]
}
EOF
        ,
        <<EOF
moved {
  from = module.PLACEHOLDER.module.gitlab[0].gitlab_project_variable.site_aws_access_key_id["${p}"]
  to   = module.PLACEHOLDER.module.gitlab[0].gitlab_project_variable.this["${p}-AWS_ACCESS_KEY_ID"]
}
EOF
        ,
        <<EOF
moved {
  from = module.PLACEHOLDER.module.gitlab[0].gitlab_project_variable.site_aws_secret_access_key["${p}"]
  to   = module.PLACEHOLDER.module.gitlab[0].gitlab_project_variable.this["${p}-AWS_SECRET_ACCESS_KEY"]
}
EOF
        ,
        <<EOF
moved {
  from = module.PLACEHOLDER.module.gitlab[0].gitlab_project_variable.site_aws_role_arn["${p}"]
  to   = module.PLACEHOLDER.module.gitlab[0].gitlab_project_variable.this["${p}-AWS_ROLE_ARN"]
}
EOF
      ]
  ]))}"
}
