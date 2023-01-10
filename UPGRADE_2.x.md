# Upgrade from v1.x to v2.x

## Basic

Old

```terraform
module "static-site" {
  source  = "cookielab/static-site/aws"
  version = "~> 1.0"

  domain         = "www.example.com"
  domain_zone_id = aws_route53_zone.example_com.zone_id
  s3_bucket_name = "example_com_web"
}
```

New

```terraform
module "static-site" {
  source  = "cookielab/static-site/aws"
  version = "~> 2.0"

  domains        = ["www.example.com"]
  domain_zone_id = aws_route53_zone.example_com.zone_id
  s3_bucket_name = "example_com_web"
}
```

## Wildcard

Old

```terraform
module "static-site" {
  source  = "cookielab/static-site/aws"
  version = "~> 1.0"

  domain         = "app.example.com"
  domain_zone_id = aws_route53_zone.example_com.zone_id
  s3_bucket_name = "example_com_web"
  wildcard       = true
}
```

New

```terraform
module "static-site" {
  source  = "cookielab/static-site/aws"
  version = "~> 2.0"

  domains = ["app.example.com", "*.app.example.com"]
  domain_zone_id = aws_route53_zone.example_com.zone_id
  s3_bucket_name = "example_com_web"
}
```

## Wildcard only

Old

```terraform
module "static-site" {
  source  = "cookielab/static-site/aws"
  version = "~> 1.0"

  domain         = "app.example.com"
  domain_zone_id = aws_route53_zone.example_com.zone_id
  s3_bucket_name = "example_com_web"
  wildcard       = true
  wildcard_only  = true
}
```

New

```terraform
module "static-site" {
  source  = "cookielab/static-site/aws"
  version = "~> 2.0"

  domains = ["*.app.example.com"]
  domain_zone_id = aws_route53_zone.example_com.zone_id
  s3_bucket_name = "example_com_web"
}
```
