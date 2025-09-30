variable "repos" {
  type = map(object({
    name        = string
    description = string
    private     = bool
    has_issues  = bool
    has_projects= bool
    has_wiki    = bool
    template    = bool
  }))
}
