variable "project_ids" {
  description = "List of IDs of GitLab projects in which the CI/CD variables will be created"
  type        = list(string)
}

variable "cicd_variables" {
  description = "list of additional GitLab CI/CD variables"
  type = list(object({
    protected         = optional(bool, false)
    hidden            = optional(bool, false)
    masked            = optional(bool, false)
    raw               = optional(bool, true)
    key               = string
    value             = string
    environment_scope = optional(string, "*")
  }))
  default = []
}
