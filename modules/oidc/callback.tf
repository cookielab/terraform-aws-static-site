# Callback Lambda
data "archive_file" "callback_lambda_zip" {
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
  runtime          = "nodejs18.x"
  filename         = data.archive_file.callback_lambda_zip[0].output_path
  source_code_hash = data.archive_file.callback_lambda_zip[0].output_base64sha256
  publish          = true

  environment {
    variables = {
      OIDC_CONFIG_JSON = local.oidc_config_json
    }
  }

  tags = var.tags
}

# API Gateway pro callback
resource "aws_apigatewayv2_api" "callback" {
  count         = local.enabled ? 1 : 0
  name          = "${var.project_name}-oidc-callback-api"
  protocol_type = "HTTP"

  tags = var.tags
}

resource "aws_apigatewayv2_integration" "callback" {
  count                  = local.enabled ? 1 : 0
  api_id                 = aws_apigatewayv2_api.callback[0].id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.oidc_callback[0].invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "callback" {
  count     = local.enabled ? 1 : 0
  api_id    = aws_apigatewayv2_api.callback[0].id
  route_key = "GET /callback"
  target    = "integrations/${aws_apigatewayv2_integration.callback[0].id}"
}

resource "aws_apigatewayv2_stage" "callback" {
  count       = local.enabled ? 1 : 0
  api_id      = aws_apigatewayv2_api.callback[0].id
  name        = "$default"
  auto_deploy = true

  tags = var.tags
}

resource "aws_lambda_permission" "allow_apigw_callback" {
  count         = local.enabled ? 1 : 0
  statement_id  = "AllowAPIGatewayInvokeCallback"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.oidc_callback[0].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.callback[0].execution_arn}/*/*"
}
