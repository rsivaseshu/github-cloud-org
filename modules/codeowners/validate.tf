locals {
  referenced_repos = distinct([for k, b in var.codeowners : b.repository])
  missing_repos = [ for r in local.referenced_repos : r if length(var.repos) > 0 && !contains(keys(var.repos), r) ]
  empty_entries = [ for k, b in var.codeowners : k if length(b.entries) == 0 ]
}

resource "null_resource" "codeowners_validations" {
  count = (length(local.missing_repos) > 0 || length(local.empty_entries) > 0) ? 1 : 0

  triggers = {
    missing_repos = join(",", local.missing_repos)
    empty_entries = join(",", local.empty_entries)
  }
}

output "codeowners_validation" {
  value = {
    missing_repos = local.missing_repos
    empty_entries = local.empty_entries
  }
  depends_on = [null_resource.codeowners_validations]
}
