resource "github_team" "teams" {
  for_each = var.teams
  name     = each.key
  description = each.value.description
  privacy  = lookup(each.value, "privacy", "closed")
}

locals {
  membership_entries = flatten([
    for t_name, t in var.teams : [
      for m in lookup(t, "members", []) : {
        key    = "${t_name}:${m}"
        team   = t_name
        member = m
      }
    ]
  ])

  membership_map = { for e in local.membership_entries : e.key => e }
}

resource "github_team_membership" "memberships" {
  for_each = local.membership_map

  team_id  = github_team.teams[each.value.team].id
  username = each.value.member
  role     = "member"
}

output "team_ids" {
  description = "Map of team logical names to github team ids"
  value = { for k, t in github_team.teams : k => t.id }
}

