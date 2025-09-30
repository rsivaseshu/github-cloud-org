locals {
  label_items = flatten([
    for repo, labs in var.labels : [
      for lab in labs : {
        repo = repo
        name = lab.name
        color = lab.color
        description = lab.description
      }
    ]
  ])
}

resource "github_issue_label" "by_repo_and_name" {
  for_each   = { for l in local.label_items : "${l.repo}:${l.name}" => l }
  repository = each.value.repo
  name       = each.value.name
  color      = each.value.color
  description = each.value.description
}
