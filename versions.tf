terraform {
  required_version = ">= 1.5, < 2.0"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 6.0"
      configuration_aliases = [aws.us_east_1]
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = ">= 15.7, < 19.0"
    }
  }
}
