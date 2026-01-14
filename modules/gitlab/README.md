# Terraform module for static site hosting propagating gitlab variables

This module will setup GitLab CI variables for static website deployment.


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5, < 2.0 |
| <a name="requirement_gitlab"></a> [gitlab](#requirement\_gitlab) | >= 18.0, < 19.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_gitlab"></a> [gitlab](#provider\_gitlab) | >= 18.0, < 19.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [gitlab_project_variable.this](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/project_variable) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cicd_variables"></a> [cicd\_variables](#input\_cicd\_variables) | list of additional GitLab CI/CD variables | <pre>list(object({<br/>    protected         = optional(bool, false)<br/>    hidden            = optional(bool, false)<br/>    masked            = optional(bool, false)<br/>    raw               = optional(bool, true)<br/>    key               = string<br/>    value             = string<br/>    environment_scope = optional(string, "*")<br/>  }))</pre> | `[]` | no |
| <a name="input_project_ids"></a> [project\_ids](#input\_project\_ids) | List of IDs of GitLab projects in which the CI/CD variables will be created | `list(string)` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->