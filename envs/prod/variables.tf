variable "teams" {
  type = map(object({
    description = string
    privacy     = string
    members     = list(string)
  }))
}

variable "github_org" {
  type = string
}

variable "tfstate_bucket" {
  type = string
}

variable "github_token" {
  type = string
  sensitive = true
}

variable "repos" {
  type = map(object({
    name        = string
    description = string
    private     = bool
    has_issues  = bool
    has_projects = bool
    has_wiki    = bool
    template    = bool
  }))
}

variable "branch_protections" {
  type = map(object({
    repo      = string
    pattern   = string
    required_approving_review_count = number
    require_status_checks = bool
    required_status_checks = list(string)
    enforce_admins = bool
  }))
}

variable "labels" {
  type = map(list(object({
    name        = string
    color       = string
    description = string
  })))
}

variable "permissions" {
  type = map(object({
    repo  = string
    teams = map(string)
    users = map(string)
  }))
}

variable "codeowners" {
  type = map(object({
    repository = string
    entries    = map(list(string))
  }))
  default = {}
}
