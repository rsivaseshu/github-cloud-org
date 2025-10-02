# CODEOWNERS module

Creates or updates `.github/CODEOWNERS` files in repositories.

Inputs
- `codeowners` (map): map of blocks each with:
  - `repository`: logical repo key (or explicit repo name)
  - `entries`: map of path -> list of GitHub usernames (without `@`)
- `repos` (map): optional map of logical repo keys to actual repo names (pass `module.repos.repo_names`).

Example in an environment module:

module "codeowners" {
  source = "../../modules/codeowners"
  codeowners = var.codeowners
  repos = module.repos.repo_names
}
