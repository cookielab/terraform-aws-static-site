# Terraform module for static site hosting propagating gitlab variables

This module will setup GitLab CI variables for static website deployment.


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5, < 2.0 |
| <a name="requirement_gitlab"></a> [gitlab](#requirement\_gitlab) | >= 15.7, < 19.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_gitlab"></a> [gitlab](#provider\_gitlab) | >= 15.7, < 19.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [gitlab_project_variable.aws_default_region](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/project_variable) | resource |
| [gitlab_project_variable.cloudfront_distribution_id](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/project_variable) | resource |
| [gitlab_project_variable.extra](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/project_variable) | resource |
| [gitlab_project_variable.s3_bucket](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/project_variable) | resource |
| [gitlab_project_variable.site_aws_access_key_id](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/project_variable) | resource |
| [gitlab_project_variable.site_aws_role_arn](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/project_variable) | resource |
| [gitlab_project_variable.site_aws_secret_access_key](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/project_variable) | resource |
| [gitlab_project.this](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_access_key_id"></a> [aws\_access\_key\_id](#input\_aws\_access\_key\_id) | n/a | `string` | n/a | yes |
| <a name="input_aws_cloudfront_distribution_id"></a> [aws\_cloudfront\_distribution\_id](#input\_aws\_cloudfront\_distribution\_id) | n/a | `string` | n/a | yes |
| <a name="input_aws_default_region"></a> [aws\_default\_region](#input\_aws\_default\_region) | n/a | `string` | n/a | yes |
| <a name="input_aws_env_vars_suffix"></a> [aws\_env\_vars\_suffix](#input\_aws\_env\_vars\_suffix) | n/a | `string` | `""` | no |
| <a name="input_aws_role_arn"></a> [aws\_role\_arn](#input\_aws\_role\_arn) | n/a | `string` | n/a | yes |
| <a name="input_aws_s3_bucket_name"></a> [aws\_s3\_bucket\_name](#input\_aws\_s3\_bucket\_name) | n/a | `string` | n/a | yes |
| <a name="input_aws_secret_access_key"></a> [aws\_secret\_access\_key](#input\_aws\_secret\_access\_key) | n/a | `string` | n/a | yes |
| <a name="input_enable_deploy_role"></a> [enable\_deploy\_role](#input\_enable\_deploy\_role) | n/a | `bool` | n/a | yes |
| <a name="input_enable_deploy_user"></a> [enable\_deploy\_user](#input\_enable\_deploy\_user) | n/a | `bool` | n/a | yes |
| <a name="input_extra_gitlab_cicd_variables"></a> [extra\_gitlab\_cicd\_variables](#input\_extra\_gitlab\_cicd\_variables) | n/a | <pre>list(object({<br/>    protected = optional(bool, false)<br/>    masked    = optional(bool, false)<br/>    raw       = optional(bool, true)<br/>    key       = string<br/>    value     = string<br/>  }))</pre> | `[]` | no |
| <a name="input_gitlab_environment"></a> [gitlab\_environment](#input\_gitlab\_environment) | n/a | `string` | `"*"` | no |
| <a name="input_gitlab_project_ids"></a> [gitlab\_project\_ids](#input\_gitlab\_project\_ids) | n/a | `list(string)` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->