locals {
  cicd_variable_flat_list = flatten([
    for project_id in var.project_ids : [
      for variable in var.cicd_variables : {
        id         = "${project_id}-${variable.key}"
        project_id = project_id
        variable   = variable
      }
    ]
  ])

  cicd_variable_flat_map = {
    for item in local.cicd_variable_flat_list :
    item.id => merge(item.variable, { project_id = item.project_id })
  }
}

resource "gitlab_project_variable" "this" {
  for_each = local.cicd_variable_flat_map

  project = each.value.project_id

  protected = each.value.protected
  hidden    = each.value.hidden
  masked    = each.value.hidden ? "true" : each.value.masked
  raw       = each.value.raw

  key   = each.value.key
  value = each.value.value

  environment_scope = each.value.environment_scope
}
