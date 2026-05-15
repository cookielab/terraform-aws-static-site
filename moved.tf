moved {
  from = aws_cloudfront_distribution.this
  to   = module.cdn.aws_cloudfront_distribution.this[0]
}
moved {
  from = aws_cloudfront_origin_access_control.this
  to   = module.cdn.aws_cloudfront_origin_access_control.this["s3"]
}

moved {
  from = aws_iam_user.deploy[0]
  to   = module.deploy_identity.aws_iam_user.deploy[0]
}

moved {
  from = aws_iam_access_key.deploy[0]
  to   = module.deploy_identity.aws_iam_access_key.deploy[0]
}

moved {
  from = aws_iam_user_policy.deploy[0]
  to   = module.deploy_identity.aws_iam_user_policy.deploy[0]
}

moved {
  from = aws_iam_role.deploy[0]
  to   = module.deploy_identity.aws_iam_role.deploy[0]
}

moved {
  from = aws_iam_role_policy.deploy[0]
  to   = module.deploy_identity.aws_iam_role_policy.deploy[0]
}

moved {
  from = aws_cloudfront_cache_policy.oidc[0]
  to   = module.cdn.aws_cloudfront_cache_policy.this["oidc"]
}

moved {
  from = aws_cloudfront_origin_request_policy.oidc[0]
  to   = module.cdn.aws_cloudfront_origin_request_policy.this["oidc"]
}

moved {
  from = aws_cloudfront_response_headers_policy.this[0]
  to   = module.cdn.aws_cloudfront_response_headers_policy.this["headers"]
}

moved {
  from = aws_kms_key.this[0]
  to   = module.kms.aws_kms_key.this[0]
}

