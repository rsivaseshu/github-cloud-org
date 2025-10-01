resource "github_repository" "repos" {
  for_each    = var.repos
  name        = each.value.name
  description = each.value.description
  visibility  = each.value.private ? "private" : "public"
  has_issues  = lookup(each.value, "has_issues", true)
  has_projects= lookup(each.value, "has_projects", false)
  has_wiki    = lookup(each.value, "has_wiki", false)
  is_template = lookup(each.value, "template", false)
}

output "repo_names" {
  description = "Map of logical repo keys to actual repository names"
  value = { for k, r in var.repos : k => r.name }
}
