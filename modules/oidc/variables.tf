variable "application_domain" {
  type        = string
  description = "Application domain for redirect after oidc login"
}

variable "project_name" {
  description = "Prefix pro pojmenování zdrojů"
  type        = string
  default     = "static-site"
}

variable "oidc" {
  description = "Seznam OIDC providerů"
  type = list(object({
    application_name = string
    application_id   = string
    client_secret    = string
    auth_url         = string
    token_url        = string
  }))
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
