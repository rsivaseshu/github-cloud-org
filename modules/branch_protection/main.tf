data "github_repository" "repo" {
  for_each = { for k,v in var.branch_protections : v.repo => v }
  full_name = "${var.org}/${each.key}"
}

resource "github_branch_protection" "bp" {
  for_each = var.branch_protections

  repository_id = data.github_repository.repo[each.value.repo].node_id
  pattern       = each.value.pattern

  required_pull_request_reviews {
    required_approving_review_count = each.value.required_approving_review_count
  }

  require_signed_commits = false
  allow_deletions = false
  allow_force_pushes = false
  enforce_admins = each.value.enforce_admins

  dynamic "required_status_checks" {
    for_each = each.value.require_status_checks ? [1] : []
    content {
      strict = true
      contexts = each.value.required_status_checks
    }
  }
}
