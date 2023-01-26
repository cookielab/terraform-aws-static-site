# Terraform module for static site hosting propagating gitlab variables

This module will setup GitLab CI variables for static website deployment.

## Requirements

| Name                                                                     | Version       |
| ------------------------------------------------------------------------ | ------------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.1, < 2.0 |
| <a name="requirement_gitlab"></a> [gitlab](#requirement_gitlab)          | ~> 15.7       |

## Providers

| Name                                                      | Version |
| --------------------------------------------------------- | ------- |
| <a name="provider_gitlab"></a> [gitlab](#provider_gitlab) | ~> 15.7 |

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
