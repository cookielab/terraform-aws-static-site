terraform {
  required_version = ">= 1.5, < 2.0"

  required_providers {
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "< 18.1"
    }
  }
}
