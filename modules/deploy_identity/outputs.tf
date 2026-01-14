output "deploy_role_arn" {
  description = "IAM Role ARN of the deploy role"
  value       = var.enable_deploy_role ? aws_iam_role.deploy[0].arn : null
  sensitive   = true
}

output "deploy_user_arn" {
  description = "IAM User ARN of the deploy user"
  value       = var.enable_deploy_user ? aws_iam_user.deploy[0].arn : null
  sensitive   = true
}

output "deploy_instance_profile" {
  description = "Instance profile name with the deploy role attached"
  value       = var.create_instance_profile ? aws_iam_instance_profile.deploy[0].arn : null
}

output "aws_access_key_id" {
  description = "AWS_ACCESS_KEY_ID of the deploy user"
  value       = var.enable_deploy_user ? aws_iam_access_key.deploy[0].id : null
}

output "aws_secret_access_key" {
  description = "AWS_SECRET_ACCESS_KEY of the deploy user"
  value       = var.enable_deploy_user ? aws_iam_access_key.deploy[0].secret : null
  sensitive   = true
}
