locals {
  team_perm_entries = flatten([
    for p_name, p in var.permissions : [
      for team_name, perm in p.teams : {
        key        = "${p_name}:${team_name}"
        repo       = p.repo
        team       = team_name
        permission = perm
      }
    ]
  ])

  team_perms_map = { for e in local.team_perm_entries : e.key => e }

  user_perm_entries = flatten([
    for p_name, p in var.permissions : [
      for user, perm in p.users : {
        key        = "${p_name}:${user}"
        repo       = p.repo
        user       = user
        permission = perm
      }
    ]
  ])

  user_perms_map = { for e in local.user_perm_entries : e.key => e }
}

// Create team <-> repository permissions
resource "github_team_repository" "team_repo_perms" {
  for_each = local.team_perms_map

  team_id    = var.team_ids[each.value.team]
  repository = var.repos[each.value.repo]
  permission = each.value.permission
}

// Create user <-> repository collaborator permissions
resource "github_repository_collaborator" "user_repo_perms" {
  for_each = local.user_perms_map

  repository = var.repos[each.value.repo]
  username   = each.value.user
  permission = each.value.permission
}
