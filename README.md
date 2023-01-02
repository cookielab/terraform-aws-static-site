# Terraform module for static site hosting

This module will create S3 bucket as storage for site and connect it with CloudFront for exposing it to public. It also creates TLS certificates for it.

<!-- BEGIN_AUTOMATED_TF_DOCS_BLOCK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0, < 2.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.32 |
| <a name="requirement_gitlab"></a> [gitlab](#requirement\_gitlab) | ~> 15.7 |

Basic usage of this module is as follows:

```hcl
module "example" {
	 source  = "<module-path>"

	 # Required variables
	 domain  = 
	 domain_zone_id  = 
	 s3_bucket_name  = 

	 # Optional variables
	 cloudfront_price_class  = "PriceClass_100"
	 gitlab_environment  = "*"
	 gitlab_project_id  = null
	 logs_bucket  = null
	 tags  = {}
	 wildcard  = false
	 wildcard_only  = false
}
```

## Resources

| Name | Type |
|------|------|
| [aws_cloudfront_distribution.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_origin_access_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_identity) | resource |
| [aws_iam_access_key.deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key) | resource |
| [aws_iam_user.deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user_policy.deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy) | resource |
| [aws_route53_record.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.wildcard](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [gitlab_project_variable.cloudfront_distribution_id](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/project_variable) | resource |
| [gitlab_project_variable.s3_bucket](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/project_variable) | resource |
| [gitlab_project_variable.site_aws_access_key_id](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/project_variable) | resource |
| [gitlab_project_variable.site_aws_secret_access_key](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/project_variable) | resource |
| [aws_iam_policy_document.bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudfront_price_class"></a> [cloudfront\_price\_class](#input\_cloudfront\_price\_class) | n/a | `string` | `"PriceClass_100"` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | n/a | `string` | n/a | yes |
| <a name="input_domain_zone_id"></a> [domain\_zone\_id](#input\_domain\_zone\_id) | The ID of the hosted zone for domain | `string` | n/a | yes |
| <a name="input_gitlab_environment"></a> [gitlab\_environment](#input\_gitlab\_environment) | n/a | `string` | `"*"` | no |
| <a name="input_gitlab_project_id"></a> [gitlab\_project\_id](#input\_gitlab\_project\_id) | n/a | `string` | `null` | no |
| <a name="input_logs_bucket"></a> [logs\_bucket](#input\_logs\_bucket) | n/a | `string` | `null` | no |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | n/a | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | `{}` | no |
| <a name="input_wildcard"></a> [wildcard](#input\_wildcard) | Add support for wildcard domain | `bool` | `false` | no |
| <a name="input_wildcard_only"></a> [wildcard\_only](#input\_wildcard\_only) | Add only wildcard alt domain for CF | `bool` | `false` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_access_key_id"></a> [aws\_access\_key\_id](#output\_aws\_access\_key\_id) | n/a |
| <a name="output_aws_cloudfront_distribution_id"></a> [aws\_cloudfront\_distribution\_id](#output\_aws\_cloudfront\_distribution\_id) | n/a |
| <a name="output_aws_s3_bucket_name"></a> [aws\_s3\_bucket\_name](#output\_aws\_s3\_bucket\_name) | n/a |
| <a name="output_aws_secret_access_key"></a> [aws\_secret\_access\_key](#output\_aws\_secret\_access\_key) | n/a |
<!-- END_AUTOMATED_TF_DOCS_BLOCK -->
