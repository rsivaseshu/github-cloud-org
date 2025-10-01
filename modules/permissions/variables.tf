variable "permissions" {
  description = "Map of permission blocks keyed by a name. Each block defines a repo, teams map (team_name -> permission), and users map (username -> permission)"
  type = map(object({
    repo  = string
    teams = map(string)
    users = map(string)
  }))
  default = {}

  validation {
    condition = true
    # Detailed validation of inner maps is performed below using local validations in the module
    error_message = "See module-level validations for permission entries."
  }
}

variable "repos" {
  description = "Map of repo logical names to repository names (from modules/repos output)"
  type = map(string)
}

variable "team_ids" {
  description = "Map of team names to team ids (from modules/teams output)"
  type = map(string)
}
