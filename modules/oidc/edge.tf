# Edge Lambda
resource "archive_file" "edge_lambda_zip" {
  count       = local.enabled ? 1 : 0
  type        = "zip"
  output_path = "${path.module}/lambda/edge_auth.zip"

  source {
    filename = "index.js"
    content  = file("${path.module}/lambda/edge_auth/index.js")
  }

  source {
    filename = "config.json"
    content  = local.oidc_config_json
  }
}

resource "aws_lambda_function" "edge_auth" {
  count            = local.enabled ? 1 : 0
  provider         = aws.us_east_1
  function_name    = "${var.project_name}-oidc-auth"
  role             = aws_iam_role.lambda_oidc[0].arn
  handler          = "index.handler"
  runtime          = "nodejs22.x"
  filename         = resource.archive_file.edge_lambda_zip[0].output_path
  source_code_hash = resource.archive_file.edge_lambda_zip[0].output_base64sha256
  publish          = true

  tags = var.tags
}
