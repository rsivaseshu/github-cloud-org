# Permissions module

This module applies repository permissions for teams and users.

Inputs
- `permissions` (map): keys are arbitrary names. Each value must be an object with:
  - `repo` (string): logical repo key (must match a key in `var.repos` from the repos module)
  - `teams` (map string->string): team_name -> permission (pull, triage, push, maintain, admin)
  - `users` (map string->string): username -> permission (pull, triage, push, maintain, admin)

- `repos` (map): map of logical repo keys to actual repository names (pass `module.repos.repo_names`).
- `team_ids` (map): map of team names to team ids (pass `module.teams.team_ids`).

Validation
- The module validates:
  - referenced `repo` keys exist in `repos`.
  - referenced team names exist in `team_ids`.
  - permission strings are one of: pull, triage, push, maintain, admin.

Example usage (in your environment module):

module "permissions" {
  source = "../../modules/permissions"
  permissions = var.permissions
  repos       = module.repos.repo_names
  team_ids    = module.teams.team_ids
}

Example permission entry (terraform.tfvars):

permissions = {
  service_a_perms = {
    repo = "service-a"
    teams = {
      devs = "push"
      infra = "admin"
    }
    users = {
      "alice" = "maintain"
    }
  }
}
