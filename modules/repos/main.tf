resource "github_repository" "repos" {
  for_each    = var.repos
  name        = each.value.name
  description = each.value.description
  private     = each.value.private
  has_issues  = lookup(each.value, "has_issues", true)
  has_projects= lookup(each.value, "has_projects", false)
  has_wiki    = lookup(each.value, "has_wiki", false)
  is_template = lookup(each.value, "template", false)
}
