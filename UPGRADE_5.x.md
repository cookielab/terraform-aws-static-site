# Upgrade from v4.x to v5.x

## Provider requirements

The minimum required provider versions have changed:

| Provider | v4.x | v5.x |
|---|---|---|
| `hashicorp/aws` | `>= 5.27` | `>= 6.44` |
| `gitlabhq/gitlab` | `>= 15.7, < 19.0` | `>= 18.0, < 19.0` |

The `aws.us_east_1` provider alias is no longer required. The module now handles ACM certificate creation internally without requiring a secondary provider alias. You can remove it from your root module if you only needed it for this module.

The `gitlabhq/gitlab` provider no longer needs to be declared in the root module's `required_providers` block — it is now used only within the module's sub-modules.

## Example
### Old
```terraform
module "static_site" {
  source  = "cookielab/static-site/aws"
  version = "~> 4.0"

  # setting providers is no longer needed, default aws provider will
  # be used for regional resources, us-east-1 for global resources.
  providers = {
    aws           = aws
    aws.us_east_1 = aws.vir
  }

  # `domains` and `domain_zone_id` is being removed in favor of `zones_and_domains`.
  domains        = ["example.com", "www.example.com"]
  domain_zone_id = data.aws_route53_zone.example_com.zone_id

  # `extra_domains` is being removed in favor of `zones_and_domains`.
  extra_domains = {
    "example.net"     = data.aws_route53_zone.example_net.zone_id
    "www.example.net" = data.aws_route53_zone.example_net.zone_id
    "example.org"     = data.aws_route53_zone.example_org.zone_id
    "www.example.org" = data.aws_route53_zone.example_org.zone_id
  }

  # `gitlab_project_id` (singular, string) is being removed, use `gitlab_project_ids` (plural, list of strings)
  gitlab_project_id  = "123"
  gitlab_project_ids = ["456"]

  # `aws_env_vars_suffix` is being renamed to `gitlab_aws_env_vars_suffix` 
  aws_env_vars_suffix = "_new"

  gitlab_environment = "production"

  # `extra_gitlab_cicd_variables` no longer inherits `gitlab_environment` scope.
  # Each variable will need its own `environment_scope` (default "*").
  extra_gitlab_cicd_variables = [
    {
      key   = "MY_VAR"
      value = "my-value"
    }
  ]

  # all three variables below are removed in favor of `cache_ttl` object
  min_ttl     = 0
  max_ttl     = 86400
  default_ttl = 3600

  # `logs_bucket_domain_name` is removed. The module now fetches the domain name
  # internally from the data source of `logs_bucket` bucket
  logs_bucket             = "my-logs-bucket"
  logs_bucket_domain_name = "my-logs-bucket.s3.amazonaws.com"

}
```

### New

```terraform
module "static_site" {
  source  = "cookielab/static-site/aws"
  version = "~> 5.0"

  # `zones_and_domains` is a list of objects. First item is supposed to hold
  # the zone_id and domains defined in `domains` and `domain_zone_id` inputs
  # of version v4.x
  # All other items represents `extra_domains` input of version v4.x
  # and are the subject for the moved blocks generation to outputs.
  zones_and_domains = [
    {
      zone_id = data.aws_route53_zone.example_com.zone_id
      domains = ["example.com", "www.example.com"]
    },
    {
      zone_id = data.aws_route53_zone.example_net.zone_id
      domains = ["example.net", "www.example.net"]
    },
    {
     zone_id = data.aws_route53_zone.example_org.zone_id
      domains = ["example.org", "www.example.org"]
    }
  ]

  # merged `gitlab_project_id` and `gitlab_project_ids`.
  gitlab_project_ids = ["123", "456"]

  # renamed from `aws_env_vars_suffix`.
  gitlab_aws_env_vars_suffix = "_new"

  gitlab_environment = "production"

  # `environment_scope` is now per-variable (default "*"). No longer inherited
  # from `gitlab_environment`.
  extra_gitlab_cicd_variables = [
    {
      key               = "MY_VAR"
      value             = "my-value"
      environment_scope = "production"
    },
  ]

  # replacing `min_ttl`, `max_ttl` and `default_ttl` with object `cache_ttl`
  cache_ttl = {
    min     = 0
    max     = 86400
    default = 3600
  }

  # only `logs_bucket` is needed, logs_bucket_domain_name is now read internally from data source.
  logs_bucket = "my-logs-bucket"
}

output "generated_moved_blocks" {
  value = module.static_site.moved_blocks
}
```

## Moved blocks
There are resources that have moved. These moved blocks cannot be placed within the module, since the resources in question are dynamic and the index cannot contain computed names, templates, function calls etc [dynamic moved blocks #33236](https://github.com/hashicorp/terraform/issues/33236).

To ease the migration we have put the moved blocks on the temporary output at least.
```terraform
output "moved_blocks" {
  value = module.static_site.moved_blocks
}
```

will produce output with suggested moved blocks

```
 Run following output through `sed 's/PLACEHOLDER/YOUR_MODULE_NAME/'` to generate moved blocks

 moved {
   from = module.PLACEHOLDER.aws_route53_record.extra["example.net"]
   to   = module.PLACEHOLDER.aws_route53_record.this["example.net"]
 }
 moved {
   from = module.PLACEHOLDER.aws_route53_record.extra["www.example.net"]
   to   = module.PLACEHOLDER.aws_route53_record.this["www.example.net"]
 }
 moved {
   from = module.PLACEHOLDER.aws_route53_record.extra["example.org"]
   to   = module.PLACEHOLDER.aws_route53_record.this["example.org"]
 }
 moved {
   from = module.PLACEHOLDER.aws_route53_record.extra["www.example.org"]
   to   = module.PLACEHOLDER.aws_route53_record.this["www.example.org"]
 }
 moved {
   from = module.PLACEHOLDER.module.gitlab[0].gitlab_project_variable.cloudfront_distribution_id["248"]
   to   = module.PLACEHOLDER.module.gitlab[0].gitlab_project_variable.this["248-AWS_CF_DISTRIBUTION_ID"]
 }
 moved {
   from = module.PLACEHOLDER.module.gitlab[0].gitlab_project_variable.aws_default_region["248"]
   to   = module.PLACEHOLDER.module.gitlab[0].gitlab_project_variable.this["248-AWS_DEFAULT_REGION"]
 }
 moved {
   from = module.PLACEHOLDER.module.gitlab[0].gitlab_project_variable.s3_bucket["248"]
   to   = module.PLACEHOLDER.module.gitlab[0].gitlab_project_variable.this["248-AWS_S3_BUCKET"]
 }
 moved {
   from = module.PLACEHOLDER.module.gitlab[0].gitlab_project_variable.site_aws_access_key_id["248"]
   to   = module.PLACEHOLDER.module.gitlab[0].gitlab_project_variable.this["248-AWS_ACCESS_KEY_ID"]
 }
 moved {
   from = module.PLACEHOLDER.module.gitlab[0].gitlab_project_variable.site_aws_secret_access_key["248"]
   to   = module.PLACEHOLDER.module.gitlab[0].gitlab_project_variable.this["248-AWS_SECRET_ACCESS_KEY"]
 }
 moved {
   from = module.PLACEHOLDER.module.gitlab[0].gitlab_project_variable.site_aws_role_arn["248"]
   to   = module.PLACEHOLDER.module.gitlab[0].gitlab_project_variable.this["248-AWS_ROLE_ARN"]
 }
```

Put the moved blocks into moved.tf and replace PLACEHOLDER with your module name e.g.: `static_site`.

## Other considerations
### OIDC Lambda zip paths

If you use the `oidc` feature, the Lambda zip files are no longer generated deep inside `.terraform/modules/…/`. They are now written to `${path.root}/` by default:

- `${path.root}/edge_auth.zip`
- `${path.root}/callback.zip`

If your `.gitlab-ci.yml` (or other CI configuration) references the old zip paths explicitly, update them to match the new location. You can also set custom paths via the new `oidc_edge_lambda_zip_path` and `oidc_callback_lambda_zip_path` inputs:

```terraform
module "static_site" {
  oidc_edge_lambda_zip_path     = "lambda/edge_auth.zip"
  oidc_callback_lambda_zip_path = "lambda/callback.zip"
}
```
