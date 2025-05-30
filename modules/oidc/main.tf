# tflint-ignore: terraform_unused_declarations
data "aws_region" "current" {}
# tflint-ignore: terraform_unused_declarations
data "aws_caller_identity" "current" {}

resource "gitlab_application" "this" {
  count = var.oidc_provider == "gitlab" ? 1 : 0

  name         = var.oidc_application_name
  redirect_uri = var.oidc_redirect_uri

  scopes = [
    "openid",
    "read_user",
    "profile",
    "email"
  ]
}

data "aws_iam_policy_document" "trust" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "edge_lambda_role" {
  name               = "${var.oidc_application_name}-edge"
  assume_role_policy = data.aws_iam_policy_document.trust.json
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.edge_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "edge_auth_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/edge_auth"
  output_path = "${path.module}/lambda/edge_auth.zip"
}

resource "aws_lambda_function" "edge_auth" {
  function_name = var.oidc_application_name
  role          = aws_iam_role.edge_lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs22.x"
  filename      = data.archive_file.edge_auth_zip.output_path
  publish       = true

  environment {
    variables = {
      GITLAB_CLIENT_ID = gitlab_application.this.application_id
    }
  }
}


resource "aws_iam_role" "callback_lambda_role" {
  name = "${var.oidc_application_name}-callback"

  assume_role_policy = data.aws_iam_policy_document.trust.json
}

resource "aws_iam_role_policy_attachment" "callback_lambda_basic" {
  role       = aws_iam_role.callback_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "callback_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/auth_callback"
  output_path = "${path.module}/lambda/auth_callback.zip"
}

resource "aws_lambda_function" "auth_callback" {
  function_name = "${var.oidc_application_name}-callback"
  role          = aws_iam_role.callback_lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs22.x"
  filename      = data.archive_file.callback_lambda_zip.output_path

  environment {
    variables = {
      GITLAB_CLIENT_ID     = gitlab_application.oidc.application_id
      GITLAB_CLIENT_SECRET = gitlab_application.oidc.secret
      REDIRECT_URI         = var.oidc_redirect_uri
    }
  }
}

resource "aws_apigatewayv2_api" "http_api" {
  name          = "${var.oidc_application_name}-http-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "callback_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.auth_callback.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "callback_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /auth/callback"
  target    = "integrations/${aws_apigatewayv2_integration.callback_integration.id}"
}

resource "aws_lambda_permission" "allow_api_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auth_callback.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}
