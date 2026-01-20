# Callback Lambda
resource "archive_file" "callback_lambda_zip" {
  count       = local.enabled ? 1 : 0
  type        = "zip"
  source_file = "${path.module}/lambda/callback/index.js"
  output_path = "${path.module}/lambda/callback.zip"
}

resource "aws_lambda_function" "oidc_callback" {
  count            = local.enabled ? 1 : 0
  function_name    = "${var.project_name}-oidc-callback"
  role             = aws_iam_role.lambda_oidc[0].arn
  handler          = "index.handler"
  runtime          = "nodejs22.x"
  filename         = resource.archive_file.callback_lambda_zip[0].output_path
  source_code_hash = resource.archive_file.callback_lambda_zip[0].output_base64sha256
  publish          = true

  environment {
    variables = {
      OIDC_CONFIG_JSON = local.oidc_config_json
    }
  }

  tags = var.tags
}

resource "aws_lambda_function_url" "oidc_callback" {
  count              = local.enabled ? 1 : 0
  function_name      = aws_lambda_function.oidc_callback[0].function_name
  authorization_type = "NONE"
}
