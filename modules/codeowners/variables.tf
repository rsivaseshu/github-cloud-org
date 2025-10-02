variable "codeowners" {
  description = "Map of codeowner blocks keyed by name. Each block contains repository (logical key or repo name) and entries map(path -> list(string owners))."
  type = map(object({
    repository = string
    entries    = map(list(string))
  }))
  default = {}
}

variable "repos" {
  description = "Optional map of logical repo keys to actual repo names (pass module.repos.repo_names if available)"
  type = map(string)
  default = {}
}

variable "create_pr" {
  description = "If true, create a branch and open a pull request instead of committing directly to the base branch."
  type = bool
  default = true
}

variable "pr_base" {
  description = "Base branch for pull requests"
  type = string
  default = "main"
}

variable "pr_title_prefix" {
  description = "Optional prefix for PR titles"
  type = string
  default = "[infra]"
}

