variable "project_ids" {
  description = "List of IDs of GitLab projects in which the CI/CD variables will be created"
  type        = list(string)
}

variable "cicd_variables" {
  description = "list of additional GitLab CI/CD variables"
  type = list(object({
    key               = string
    value             = string
    protected         = optional(bool, false)
    hidden            = optional(bool, false)
    masked            = optional(bool, false)
    raw               = optional(bool, true)
    environment_scope = optional(string, "*")
    variable_type     = optional(string, "env_var")
    description       = optional(string, "")
  }))
  default = []
}
