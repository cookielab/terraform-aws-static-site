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
  value = aws_cloudfront_distribution.this.id
}

output "aws_access_key_id" {
  value = var.enable_deploy_user ? aws_iam_access_key.deploy[0].id : null
}

output "aws_secret_access_key" {
  value     = var.enable_deploy_user ? aws_iam_access_key.deploy[0].secret : null
  sensitive = true
}

output "deploy_role_arn" {
  description = "ARN of the deploy IAM role"
  value       = var.enable_deploy_role ? module.deploy_identity.deploy_role_arn : null
}

output "deploy_instance_profile" {
  description = "Instance profile name with the deploy role attached"
  value       = var.create_instance_profile ? aws_iam_instance_profile.deploy[0].arn : null
}

output "s3_kms_key_arn" {
  value = var.encrypt_with_kms ? aws_kms_key.this[0].arn : null
}

output "oidc_callback_url" {
  value = module.oidc.oidc_callback_url_base != null ? module.oidc.oidc_callback_url_base : null
}
