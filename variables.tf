variable "github_token" {
  type        = string
  description = "GitHub token with admin:org and repo permissions"
  sensitive   = true
}

variable "github_org" {
  type        = string
  description = "GitHub organization name"
}

variable "tfstate_bucket" {
  type        = string
  description = "GCS bucket name for terraform state"
}

variable "teams" {
  type = map(object({
    description = string
    privacy     = string
    members     = list(string)
  }))
  default = {}
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
  default = {}
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
  default = {}
}

variable "labels" {
  type = map(list(object({
    name        = string
    color       = string
    description = string
  })))
  default = {}
}
