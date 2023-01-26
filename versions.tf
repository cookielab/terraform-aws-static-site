terraform {
  required_version = ">= 1.1, < 2.0"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 4.32"
      configuration_aliases = [aws.us_east_1]
    }
  }
}
