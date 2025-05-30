locals {
  enabled = length(var.oidc) > 0

  oidc_config = {
    for cfg in var.oidc : cfg.application_name => {
      client_id            = cfg.application_id
      client_secret        = cfg.client_secret
      auth_url             = cfg.auth_url
      token_url            = cfg.token_url
      redirect_uri         = "https://${var.application_domain}/callback?auth=${cfg.application_name}"
      session_secret       = random_string.session_secret.result
      redirect_after_login = "https://${var.application_domain}"
      session_duration     = cfg.session_duration
    }
  }

  oidc_config_json = local.enabled ? jsonencode(local.oidc_config) : null
}

resource "random_string" "session_secret" {
  length  = 64
  special = true
}

data "aws_iam_policy_document" "lambda_assume" {
  count = local.enabled ? 1 : 0
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com", "edgelambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_oidc" {
  count              = local.enabled ? 1 : 0
  name               = "zvirt-${var.project_name}-oidc"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume[0].json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "lambda_edge" {
  count      = local.enabled ? 1 : 0
  role       = aws_iam_role.lambda_oidc[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
