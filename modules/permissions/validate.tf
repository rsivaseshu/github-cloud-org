locals {
  allowed_perms = ["pull","triage","push","maintain","admin"]

  all_repo_keys = keys(var.repos)

  // Flatten all referenced repo keys from permissions
  referenced_repos = distinct([for p_name, p in var.permissions : p.repo])

  // Flatten referenced team names
  referenced_team_names = distinct(flatten([for p_name, p in var.permissions : keys(p.teams)]))

  // Flatten referenced users (just for completeness)
  referenced_usernames = distinct(flatten([for p_name, p in var.permissions : keys(p.users)]))

  // Validate repo keys exist
  invalid_repos = [for r in local.referenced_repos : r if !contains(local.all_repo_keys, r)]

  // Validate team names exist in provided team_ids map
  invalid_teams = [for t in local.referenced_team_names : t if !contains(keys(var.team_ids), t)]

  // Validate permission strings for teams and users and produce labeled entries
  team_invalids = flatten([for p_name, p in var.permissions : [for tn in keys(p.teams) : contains(local.allowed_perms, p.teams[tn]) ? "" : "team:${p_name}:${tn}:${p.teams[tn]}"]])

  user_invalids = flatten([for p_name, p in var.permissions : [for un in keys(p.users) : contains(local.allowed_perms, p.users[un]) ? "" : "user:${p_name}:${un}:${p.users[un]}"]])

  invalid_perm_entries = [for e in concat(local.team_invalids, local.user_invalids) : e if e != ""]
}

// Use terraform's validation by failing with an explanatory message via a local value and an explicit 'false' condition
// The usage causes terraform validate/plan to show the error string when the condition is false.
resource "null_resource" "permissions_validation" {
  count = (
    length(local.invalid_repos) > 0 || length(local.invalid_teams) > 0 || length(local.invalid_perm_entries) > 0
  ) ? 1 : 0

  triggers = {
    invalid_repos        = join(",", local.invalid_repos)
    invalid_teams        = join(",", local.invalid_teams)
    invalid_perm_entries = join(",", local.invalid_perm_entries)
  }
}

// If validation fails, produce readable messages with explicit `terraform` `validation`-like errors using a data resource interpolation
output "permissions_validation_error" {
  value = {
    invalid_repos = local.invalid_repos
    invalid_teams = local.invalid_teams
    invalid_perms = local.invalid_perm_entries
  }

  description = "Non-empty if validation found problems. If non-empty, fix your permissions entries."
  sensitive = false
  depends_on = [null_resource.permissions_validation]
}
