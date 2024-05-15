output "aws_s3_bucket_name" {
  value = module.s3_bucket.s3_bucket_id
}

output "aws_cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.this.id
}

output "aws_access_key_id" {
  value = aws_iam_access_key.deploy.id
}

output "aws_secret_access_key" {
  value     = aws_iam_access_key.deploy.secret
  sensitive = true
}

output "aws_s3_bucket_arn" {
  value = module.s3_bucket.s3_bucket_arn
}

output "aws_s3_bucket_regional_domain_name" {
  value = module.s3_bucket.s3_bucket_bucket_regional_domain_name
}
