output "lambda_edge_function_arn" {
  description = "ARN of edge Lambda function"
  value       = local.enabled ? aws_lambda_function.edge_auth[0].qualified_arn : null
}

output "oidc_callback_url_base" {
  description = "Base URL for OIDC callback endpoint"
  value       = local.enabled ? aws_lambda_function_url.oidc_callback[0].function_url : null
}

output "oidc_callback_url" {
  description = "OIDC callback URL for Redirect URI in the OIDC application"
  value       = local.enabled ? "${aws_lambda_function_url.oidc_callback[0].function_url}/callback" : null
}
