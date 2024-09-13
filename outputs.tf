output "aws_s3_bucket_name" {
  value = var.s3_bucket_name_create == var.s3_bucket_name ? module.s3_bucket.s3_bucket_id : var.s3_bucket_name
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
