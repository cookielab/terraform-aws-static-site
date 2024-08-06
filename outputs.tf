output "aws_s3_bucket_name" {
  value = module.s3_bucket.s3_bucket_id
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

output "aws_s3_bucket_arn" {
  value = module.s3_bucket.s3_bucket_arn
}

output "aws_s3_bucket_regional_domain_name" {
  value = module.s3_bucket.s3_bucket_bucket_regional_domain_name
}
output "s3_kms_key_arn" {
  value = var.encrypt_with_kms ? aws_kms_key.this[0].arn : null
}
