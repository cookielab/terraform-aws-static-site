# Upgrade from v4.x to v5.x

Old

```terraform
module "static_site" {
  source  = "cookielab/static-site/aws"
  version = "~> 4.0"

  domains        = ["example.com", "www.example.com"]
  domain_zone_id = data.aws_route53_zone.example_com.zone_id

  extra_domains = {
    "example.net"     = data.aws_route53_zone.example_net.zone_id
    "www.example.net" = data.aws_route53_zone.example_net.zone_id
    "example.org"     = data.aws_route53_zone.example_org.zone_id
    "www.example.org" = data.aws_route53_zone.example_org.zone_id
  }

  project_id = "123"

  aws_env_vars_suffix = "_new"

  min_ttl     = 0
  max_ttl     = 86400
  default_ttl = 3600
}
```

New

```terraform
module "static_site" {
  source  = "cookielab/static-site/aws"
  version = "~> 5.0"

  # zones_and_domains is list of objects. First item is supposed to hold
  # the zone_id and domains defined in `domains` and `domain_zone_id` inputs
  # of version v4.x
  # All other items represents `extra_domains` input of version v4.x
  # and are the subject for the moved blocks generation.
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

  project_ids = ["123"]

  gitlab_aws_env_vars_suffix = "_new"

  cache_ttl = {
    min     = 0
    max     = 86400
    default = 3600
  }
}
```

## Moved blocks
There are resources that have moved, but moved blocks cannot be placed in the module, since the resources in question are dynamic and the index cannot contain computed names, templates, function calls etc [dynamic moved blocks #33236](https://github.com/hashicorp/terraform/issues/33236).

To ease the migration we've put the moved blocks on the output at least.
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
