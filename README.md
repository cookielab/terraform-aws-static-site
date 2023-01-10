# Terraform module for static site hosting

This module will create S3 bucket as storage for site and connect it with CloudFront for exposing it to public. It also creates TLS certificates for it.

## Usage

```terraform
module "static-site" {
  source  = "cookielab/static-site/aws"
  version = "~> 2.0"

  domains        = ["www.example.com"]
  domain_zone_id = aws_route53_zone.example_com.zone_id
  s3_bucket_name = "example_com_web"
}
```

## Requirements

| Name                                                                     | Version       |
| ------------------------------------------------------------------------ | ------------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.0, < 2.0 |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | ~> 4.32       |
| <a name="requirement_gitlab"></a> [gitlab](#requirement_gitlab)          | ~> 3.18       |

## Providers

| Name                                                      | Version |
| --------------------------------------------------------- | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws)          | ~> 4.32 |
| <a name="provider_gitlab"></a> [gitlab](#provider_gitlab) | ~> 3.18 |

## Modules

| Name                                                                 | Source                              | Version |
| -------------------------------------------------------------------- | ----------------------------------- | ------- |
| <a name="module_certificate"></a> [certificate](#module_certificate) | terraform-aws-modules/acm/aws       | 4.1.0   |
| <a name="module_s3_bucket"></a> [s3_bucket](#module_s3_bucket)       | terraform-aws-modules/s3-bucket/aws | 3.4.0   |

## Resources

| Name                                                                                                                                                        | Type        |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_cloudfront_distribution.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution)                     | resource    |
| [aws_cloudfront_origin_access_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_identity) | resource    |
| [aws_iam_access_key.deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key)                                     | resource    |
| [aws_iam_user.deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user)                                                 | resource    |
| [aws_iam_user_policy.deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy)                                   | resource    |
| [aws_route53_record.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record)                                       | resource    |
| [gitlab_project_variable.cloudfront_distribution_id](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/project_variable)        | resource    |
| [gitlab_project_variable.s3_bucket](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/project_variable)                         | resource    |
| [gitlab_project_variable.site_aws_access_key_id](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/project_variable)            | resource    |
| [gitlab_project_variable.site_aws_secret_access_key](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/project_variable)        | resource    |
| [aws_iam_policy_document.bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                 | data source |
| [aws_iam_policy_document.deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                        | data source |

## Inputs

| Name                                                                                                | Description                                                                | Type           | Default            | Required |
| --------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------- | -------------- | ------------------ | :------: |
| <a name="input_cloudfront_price_class"></a> [cloudfront_price_class](#input_cloudfront_price_class) | n/a                                                                        | `string`       | `"PriceClass_100"` |    no    |
| <a name="input_domain_zone_id"></a> [domain_zone_id](#input_domain_zone_id)                         | The ID of the hosted zone for domain                                       | `string`       | n/a                |   yes    |
| <a name="input_domains"></a> [domains](#input_domains)                                              | List of domain aliases. You can also specify wildcard eg.: `*.example.com` | `list(string)` | n/a                |   yes    |
| <a name="input_gitlab_environment"></a> [gitlab_environment](#input_gitlab_environment)             | n/a                                                                        | `string`       | `"*"`              |    no    |
| <a name="input_gitlab_project_id"></a> [gitlab_project_id](#input_gitlab_project_id)                | n/a                                                                        | `string`       | `null`             |    no    |
| <a name="input_logs_bucket"></a> [logs_bucket](#input_logs_bucket)                                  | n/a                                                                        | `string`       | `null`             |    no    |
| <a name="input_s3_bucket_name"></a> [s3_bucket_name](#input_s3_bucket_name)                         | n/a                                                                        | `string`       | n/a                |   yes    |
| <a name="input_tags"></a> [tags](#input_tags)                                                       | n/a                                                                        | `map(string)`  | `{}`               |    no    |

## Outputs

| Name                                                                                                                          | Description |
| ----------------------------------------------------------------------------------------------------------------------------- | ----------- |
| <a name="output_aws_access_key_id"></a> [aws_access_key_id](#output_aws_access_key_id)                                        | n/a         |
| <a name="output_aws_cloudfront_distribution_id"></a> [aws_cloudfront_distribution_id](#output_aws_cloudfront_distribution_id) | n/a         |
| <a name="output_aws_s3_bucket_name"></a> [aws_s3_bucket_name](#output_aws_s3_bucket_name)                                     | n/a         |
| <a name="output_aws_secret_access_key"></a> [aws_secret_access_key](#output_aws_secret_access_key)                            | n/a         |
