output "lambda_edge_function_arn" {
  value       = local.enabled ? aws_lambda_function.edge_auth[0].qualified_arn : null
  description = "ARN Lambda funkce pro edge použití"
}

output "oidc_callback_url_base" {
  value       = local.enabled ? aws_lambda_function_url.oidc_callback[0].function_url : null
  description = "Base URL for OIDC callback endpoint"
}

output "oidc_callback_url" {
  value       = local.enabled ? "${aws_lambda_function_url.oidc_callback[0].function_url}/callback" : null
  description = "Callback URL pro OIDC redirect"
}
