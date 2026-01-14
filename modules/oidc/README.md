# Terraform module for static site hosting configuring OIDC authentication

This module will configure OIDC authentication for the application.

## Usage

```terraform
locals {
  application_domain = "www.example.com"
}

module "oidc" {
  source = "./modules/oidc"

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  oidc = [
    {
      application_name = "first_provider"
      application_id   = "APPLICATION_ID_1"
      client_secret    = "CLIENT_SECRET_1
      auth_url         = "https://gitlab.example.com/oauth/authorize"
      token_url        = "https://gitlab.example.com/oauth/token"
      session_duration = 30 * 86400
    },
    {
      application_name = "second_provider"
      application_id   = "APPLICATION_ID_2"
      client_secret    = "CLIENT_SECRET_2
      auth_url         = "https://gitlab.com/oauth/authorize"
      token_url        = "https://gitlab.com/oauth/token"
    }
  ]
  application_domain = local.application_domain
  project_name       = replace(local.applicaton_domain, ".", "-")
}
```

Variable `oidc` accepts list of providers application details. When mutliple OIDC providers is present, the first is picked up automatically. To choose another provider go to URL `https://www.example.com/?auth=second_provider`

## TODO
Generate an HTML file on S3 populeted with links to pick a provider. Redirect user when no session cookie is present.
```html
<h1>Choose authentication method</h1>
<ul>
  <li>
    <a href="/?auth=first_provider">First provider</a>
  </li>
  <li>
    <a href="/?auth=second_provider">Second provider</a>
  </li>
</ul>
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5, < 2.0 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | ~> 2.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | ~> 2.7 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6 |
| <a name="provider_aws.us_east_1"></a> [aws.us\_east\_1](#provider\_aws.us\_east\_1) | ~> 6 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.lambda_oidc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.lambda_edge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.edge_auth](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_function.oidc_callback](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_function_url.oidc_callback](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function_url) | resource |
| [random_string.session_secret](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [archive_file.callback_lambda_zip](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [archive_file.edge_lambda_zip](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_iam_policy_document.lambda_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_domain"></a> [application\_domain](#input\_application\_domain) | Application domain for redirect after oidc login | `string` | n/a | yes |
| <a name="input_oidc"></a> [oidc](#input\_oidc) | List of OIDC providers | <pre>list(object({<br/>    application_name = string<br/>    application_id   = string<br/>    client_secret    = string<br/>    auth_url         = string<br/>    token_url        = string<br/>    session_duration = optional(number, 12 * 3600)<br/>  }))</pre> | `[]` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Prefix for naming the resources | `string` | `"static-site"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Resources tags map | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lambda_edge_function_arn"></a> [lambda\_edge\_function\_arn](#output\_lambda\_edge\_function\_arn) | ARN of edge Lambda function |
| <a name="output_oidc_callback_url"></a> [oidc\_callback\_url](#output\_oidc\_callback\_url) | OIDC callback URL for Redirect URI in the OIDC application |
| <a name="output_oidc_callback_url_base"></a> [oidc\_callback\_url\_base](#output\_oidc\_callback\_url\_base) | Base URL for OIDC callback endpoint |
<!-- END_TF_DOCS -->
