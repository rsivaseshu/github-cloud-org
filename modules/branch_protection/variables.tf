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

variable "org" {
  type = string
}
