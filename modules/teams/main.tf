resource "github_team" "teams" {
  for_each = var.teams
  name     = each.key
  description = each.value.description
  privacy  = lookup(each.value, "privacy", "closed")
}

resource "github_team_membership" "memberships" {
  for_each = { for t_name, t in var.teams : "${t_name}:${t_member}" => {
    team = t_name
    member = t_member
  } for t_member in t.members }
  team_id  = github_team.teams[each.value.team].id
  username = each.value.member
  role     = "member"
}
