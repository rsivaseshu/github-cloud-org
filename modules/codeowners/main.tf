locals {
  // Build CODEOWNERS content per block
  codeowners_entries = {
    for k, b in var.codeowners : k => join("\n", [for path, owners in b.entries : "${path} ${join(" ", [for o in owners : "@${o}"])}"]) 
  }
}

// For each codeowners block we either commit directly to base (pr_base) or create branch + PR
resource "github_branch" "codeowners_branch" {
  for_each = var.create_pr ? var.codeowners : {}

  repository = contains(keys(var.repos), each.value.repository) ? var.repos[each.value.repository] : each.value.repository
  branch     = "codeowners/${each.key}/${replace(timestamp(),":","-")}" // safe branch name
  source_branch = var.pr_base
}

resource "github_repository_file" "codeowners_files_pr" {
  for_each = var.create_pr ? var.codeowners : {}

  repository = contains(keys(var.repos), each.value.repository) ? var.repos[each.value.repository] : each.value.repository
  file       = ".github/CODEOWNERS"
  content    = local.codeowners_entries[each.key]
  commit_message = "${var.pr_title_prefix} Add/update CODEOWNERS"
  branch = github_branch.codeowners_branch[each.key].branch
}

resource "github_pull_request" "codeowners_pr" {
  for_each = var.create_pr ? var.codeowners : {}

  repository = contains(keys(var.repos), each.value.repository) ? var.repos[each.value.repository] : each.value.repository
  title      = "${var.pr_title_prefix} CODEOWNERS: ${each.key}"
  head       = github_branch.codeowners_branch[each.key].branch
  base       = var.pr_base
  body       = "Add/update CODEOWNERS via infra automation"
}

// Direct commit path when create_pr = false
resource "github_repository_file" "codeowners_files_direct" {
  for_each = var.create_pr ? {} : var.codeowners

  repository = contains(keys(var.repos), each.value.repository) ? var.repos[each.value.repository] : each.value.repository
  file       = ".github/CODEOWNERS"
  content    = local.codeowners_entries[each.key]
  commit_message = "${var.pr_title_prefix} Add/update CODEOWNERS"
  branch = var.pr_base
}
