# Terraform module for static site hosting

This module will create S3 bucket as storage for site and connect it with CloudFront for exposing it to public. It also creates TLS certificates for it.

## Usage

```terraform
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "static-site" {
  source  = "cookielab/static-site/aws"
  version = "~> 2.1"

  providers = {
    aws.us_east_1 = aws.us_east_1
  }

  domains        = ["www.example.com"]
  domain_zone_id = aws_route53_zone.example_com.zone_id
  s3_bucket_name = "example_com_web"
}
```

## Requirements

| Name                                                                     | Version       |
| ------------------------------------------------------------------------ | ------------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.1, < 2.0 |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | ~> 4.32       |

## Providers

| Name                                             | Version |
| ------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | ~> 4.32 |

## Modules

| Name                                                                 | Source                              | Version |
| -------------------------------------------------------------------- | ----------------------------------- | ------- |
| <a name="module_certificate"></a> [certificate](#module_certificate) | terraform-aws-modules/acm/aws       | 4.3.1   |
| <a name="module_gitlab"></a> [gitlab](#module_gitlab)                | ./modules/gitlab                    | n/a     |
| <a name="module_s3_bucket"></a> [s3_bucket](#module_s3_bucket)       | terraform-aws-modules/s3-bucket/aws | 3.6.0   |

## Resources

| Name                                                                                                                                                        | Type        |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_cloudfront_distribution.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution)                     | resource    |
| [aws_cloudfront_origin_access_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_identity) | resource    |
| [aws_iam_access_key.deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key)                                     | resource    |
| [aws_iam_user.deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user)                                                 | resource    |
| [aws_iam_user_policy.deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy)                                   | resource    |
| [aws_route53_record.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record)                                       | resource    |
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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5, < 2.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.27 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.27 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_certificate"></a> [certificate](#module\_certificate) | terraform-aws-modules/acm/aws | 5.0.0 |
| <a name="module_gitlab"></a> [gitlab](#module\_gitlab) | ./modules/gitlab | n/a |
| <a name="module_s3_bucket"></a> [s3\_bucket](#module\_s3\_bucket) | terraform-aws-modules/s3-bucket/aws | 4.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudfront_distribution.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_origin_access_control.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_control) | resource |
| [aws_cloudfront_origin_access_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_identity) | resource |
| [aws_iam_access_key.deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key) | resource |
| [aws_iam_user.deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user_policy.deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy) | resource |
| [aws_route53_record.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_cloudfront_cache_policy.managed_caching_disabled](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_cache_policy) | data source |
| [aws_cloudfront_origin_request_policy.managed_all_viewer_and_cloudfront_headers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_origin_request_policy) | data source |
| [aws_iam_policy_document.bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudfront_price_class"></a> [cloudfront\_price\_class](#input\_cloudfront\_price\_class) | n/a | `string` | `"PriceClass_100"` | no |
| <a name="input_domain_zone_id"></a> [domain\_zone\_id](#input\_domain\_zone\_id) | The ID of the hosted zone for domain | `string` | n/a | yes |
| <a name="input_domains"></a> [domains](#input\_domains) | List of domain aliases. You can also specify wildcard eg.: `*.example.com` | `list(string)` | n/a | yes |
| <a name="input_functions"></a> [functions](#input\_functions) | n/a | <pre>object({<br>    viewer_request  = optional(string)<br>    viewer_response = optional(string)<br>  })</pre> | `{}` | no |
| <a name="input_gitlab_environment"></a> [gitlab\_environment](#input\_gitlab\_environment) | n/a | `string` | `"*"` | no |
| <a name="input_gitlab_project_id"></a> [gitlab\_project\_id](#input\_gitlab\_project\_id) | n/a | `string` | `null` | no |
| <a name="input_logs_bucket"></a> [logs\_bucket](#input\_logs\_bucket) | n/a | `string` | `null` | no |
| <a name="input_logs_bucket_domain_name"></a> [logs\_bucket\_domain\_name](#input\_logs\_bucket\_domain\_name) | n/a | `string` | `null` | no |
| <a name="input_override_status_code_403"></a> [override\_status\_code\_403](#input\_override\_status\_code\_403) | n/a | `number` | `403` | no |
| <a name="input_override_status_code_404"></a> [override\_status\_code\_404](#input\_override\_status\_code\_404) | n/a | `number` | `200` | no |
| <a name="input_proxy_paths"></a> [proxy\_paths](#input\_proxy\_paths) | n/a | <pre>list(object({<br>    origin_domain = string<br>    path_prefix   = string<br>  }))</pre> | `[]` | no |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | n/a | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_access_key_id"></a> [aws\_access\_key\_id](#output\_aws\_access\_key\_id) | n/a |
| <a name="output_aws_cloudfront_distribution_id"></a> [aws\_cloudfront\_distribution\_id](#output\_aws\_cloudfront\_distribution\_id) | n/a |
| <a name="output_aws_s3_bucket_arn"></a> [aws\_s3\_bucket\_arn](#output\_aws\_s3\_bucket\_arn) | n/a |
| <a name="output_aws_s3_bucket_name"></a> [aws\_s3\_bucket\_name](#output\_aws\_s3\_bucket\_name) | n/a |
| <a name="output_aws_s3_bucket_regional_domain_name"></a> [aws\_s3\_bucket\_regional\_domain\_name](#output\_aws\_s3\_bucket\_regional\_domain\_name) | n/a |
| <a name="output_aws_secret_access_key"></a> [aws\_secret\_access\_key](#output\_aws\_secret\_access\_key) | n/a |
<!-- END_TF_DOCS -->