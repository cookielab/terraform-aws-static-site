moved { 
  from = module.fridges_list_app.module.oidc.aws_iam_role.lambda_edge[0]
  to   = module.fridges_list_app.module.oidc.aws_iam_role.lambda_oidc[0]
}
