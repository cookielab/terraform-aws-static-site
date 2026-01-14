<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5, < 2.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6 |
| <a name="requirement_gitlab"></a> [gitlab](#requirement\_gitlab) | >= 18.0, < 19.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6 |
| <a name="provider_gitlab"></a> [gitlab](#provider\_gitlab) | >= 18.0, < 19.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_access_key.deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key) | resource |
| [aws_iam_role.deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_user.deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user_policy.deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy) | resource |
| [aws_iam_openid_connect_provider.gitlab](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_openid_connect_provider) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [gitlab_project.this](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudfront_distribution_arn"></a> [cloudfront\_distribution\_arn](#input\_cloudfront\_distribution\_arn) | CloudFront distribution ID for the IAM user/role policy | `string` | n/a | yes |
| <a name="input_enable_deploy_role"></a> [enable\_deploy\_role](#input\_enable\_deploy\_role) | Toggle IAM role creation for S3 deploy & CloudFront invalidation; This requires existing `aws_iam_openid_connect_provider` matching domain of your gitlab provider. | `bool` | `false` | no |
| <a name="input_enable_deploy_user"></a> [enable\_deploy\_user](#input\_enable\_deploy\_user) | Toggle s3 deploy user creation for S3 deploy & Cloudfront invalidation | `bool` | `true` | no |
| <a name="input_gitlab_project_ids"></a> [gitlab\_project\_ids](#input\_gitlab\_project\_ids) | Integrates with GitLab CI/CD to deploy site and invalidate CloudFront cache | `list(string)` | `[]` | no |
| <a name="input_identity_base_name"></a> [identity\_base\_name](#input\_identity\_base\_name) | The base name for the IAM user/role withtout `zvirt-` prefix and `-deploy` suffix | `string` | n/a | yes |
| <a name="input_s3_bucket_arn"></a> [s3\_bucket\_arn](#input\_s3\_bucket\_arn) | The ARN for the S3 bucket hosting the website for the IAM user/role policy | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to be set on resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_access_key_id"></a> [aws\_access\_key\_id](#output\_aws\_access\_key\_id) | AWS\_ACCESS\_KEY\_ID of the deploy user |
| <a name="output_aws_secret_access_key"></a> [aws\_secret\_access\_key](#output\_aws\_secret\_access\_key) | AWS\_SECRET\_ACCESS\_KEY of the deploy user |
| <a name="output_deploy_role_arn"></a> [deploy\_role\_arn](#output\_deploy\_role\_arn) | IAM Role ARN of the deploy role |
| <a name="output_deploy_user_arn"></a> [deploy\_user\_arn](#output\_deploy\_user\_arn) | IAM User ARN of the deploy user |
<!-- END_TF_DOCS -->