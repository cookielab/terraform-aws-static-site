# Terraform module for static site hosting propagating gitlab variables

This module will setup GitLab CI variables for static website deployment.

## Requirements

| Name                                                                     | Version       |
| ------------------------------------------------------------------------ | ------------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.1, < 2.0 |
| <a name="requirement_gitlab"></a> [gitlab](#requirement_gitlab)          | >= 15.7, < 18.0 |

## Providers

| Name                                                      | Version |
| --------------------------------------------------------- | ------- |
| <a name="provider_gitlab"></a> [gitlab](#provider_gitlab) | >= 15.7, < 18.0 |

## Modules

No modules.

## Resources

| Name                                                                                                                                                 | Type        |
| ---------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [gitlab_project_variable.cloudfront_distribution_id](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/project_variable) | resource    |
| [gitlab_project_variable.s3_bucket](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/project_variable)                  | resource    |
| [gitlab_project_variable.site_aws_access_key_id](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/project_variable)     | resource    |
| [gitlab_project_variable.site_aws_secret_access_key](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/project_variable) | resource    |
| [gitlab_project.this](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/data-sources/project)                                      | data source |

## Inputs

| Name                                                                                                                        | Description | Type     | Default | Required |
| --------------------------------------------------------------------------------------------------------------------------- | ----------- | -------- | ------- | :------: |
| <a name="input_aws_access_key_id"></a> [aws_access_key_id](#input_aws_access_key_id)                                        | n/a         | `string` | n/a     |   yes    |
| <a name="input_aws_cloudfront_distribution_id"></a> [aws_cloudfront_distribution_id](#input_aws_cloudfront_distribution_id) | n/a         | `string` | n/a     |   yes    |
| <a name="input_aws_s3_bucket_name"></a> [aws_s3_bucket_name](#input_aws_s3_bucket_name)                                     | n/a         | `string` | n/a     |   yes    |
| <a name="input_aws_secret_access_key"></a> [aws_secret_access_key](#input_aws_secret_access_key)                            | n/a         | `string` | n/a     |   yes    |
| <a name="input_gitlab_environment"></a> [gitlab_environment](#input_gitlab_environment)                                     | n/a         | `string` | `"*"`   |    no    |
| <a name="input_gitlab_project_id"></a> [gitlab_project_id](#input_gitlab_project_id)                                        | n/a         | `string` | n/a     |   yes    |

## Outputs

No outputs.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5, < 2.0 |
| <a name="requirement_gitlab"></a> [gitlab](#requirement\_gitlab) | >= 15.7, < 18.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_gitlab"></a> [gitlab](#provider\_gitlab) | >= 15.7, < 18.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [gitlab_project_variable.aws_default_region](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/project_variable) | resource |
| [gitlab_project_variable.cloudfront_distribution_id](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/project_variable) | resource |
| [gitlab_project_variable.s3_bucket](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/project_variable) | resource |
| [gitlab_project_variable.site_aws_access_key_id](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/project_variable) | resource |
| [gitlab_project_variable.site_aws_secret_access_key](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/project_variable) | resource |
| [gitlab_project.this](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_access_key_id"></a> [aws\_access\_key\_id](#input\_aws\_access\_key\_id) | n/a | `string` | n/a | yes |
| <a name="input_aws_cloudfront_distribution_id"></a> [aws\_cloudfront\_distribution\_id](#input\_aws\_cloudfront\_distribution\_id) | n/a | `string` | n/a | yes |
| <a name="input_aws_default_region"></a> [aws\_default\_region](#input\_aws\_default\_region) | n/a | `string` | n/a | yes |
| <a name="input_aws_s3_bucket_name"></a> [aws\_s3\_bucket\_name](#input\_aws\_s3\_bucket\_name) | n/a | `string` | n/a | yes |
| <a name="input_aws_secret_access_key"></a> [aws\_secret\_access\_key](#input\_aws\_secret\_access\_key) | n/a | `string` | n/a | yes |
| <a name="input_gitlab_environment"></a> [gitlab\_environment](#input\_gitlab\_environment) | n/a | `string` | `"*"` | no |
| <a name="input_gitlab_project_id"></a> [gitlab\_project\_id](#input\_gitlab\_project\_id) | n/a | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
