variable "application_domain" {
  description = "Application domain for redirect after oidc login"
  type        = string
}

variable "project_name" {
  description = "Prefix for naming the resources"
  type        = string
  default     = "static-site"
}

variable "oidc" {
  description = "List of OIDC providers"
  type = list(object({
    application_name = string
    application_id   = string
    client_secret    = string
    auth_url         = string
    token_url        = string
    session_duration = optional(number, 12 * 3600)
  }))
  default = []
}

variable "tags" {
  description = "Resources tags map"
  type        = map(string)
  default     = {}
}
