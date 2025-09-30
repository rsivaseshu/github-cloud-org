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
