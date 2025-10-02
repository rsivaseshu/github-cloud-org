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

Previewing CODEOWNERS locally
-----------------------------
There's a small helper script at `tools/render_codeowners.py` that can render the CODEOWNERS content from a tfvars file. Example:

  python tools/render_codeowners.py envs/prod/terraform.tfvars

Or use the example file:

  python tools/render_codeowners.py envs/prod/codeowners-example.tfvars

