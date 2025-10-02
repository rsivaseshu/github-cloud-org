module "teams" {
  source = "../../modules/teams"
  teams  = var.teams
}

module "repos" {
  source = "../../modules/repos"
  repos  = var.repos
}

module "branch_protections" {
  source = "../../modules/branch_protection"
  branch_protections = var.branch_protections
  org = var.github_org
}

module "labels" {
  source = "../../modules/labels"
  labels = var.labels
}

module "permissions" {
  source = "../../modules/permissions"
  permissions = var.permissions
  repos       = module.repos.repo_names
  team_ids    = module.teams.team_ids
}

module "codeowners" {
  source = "../../modules/codeowners"
  codeowners = var.codeowners
  repos = module.repos.repo_names
}
