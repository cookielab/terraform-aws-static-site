terraform {
  required_version = ">= 1.0, < 2.0"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 4.32"
      configuration_aliases = [aws.us_east_1]
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "~> 3.18"
    }
  }
}
