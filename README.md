## Repository permissions automation

This repository includes a `modules/permissions` Terraform module to attach team and user permissions to repositories.

Quick usage:

- Add entries to `envs/<env>/terraform.tfvars` under `permissions` (see `envs/prod/terraform.tfvars` for an example).
- The module will validate that referenced repos and teams exist and that permission strings are valid.

CI: run `cloudbuild-permissions.yaml` (or `cloudbuild.yaml`) to plan and optionally apply. The apply step is gated with the `_TF_APPLY` substitution; set it to "true" when you really want to apply.

# GitHub Org As Code — Terraform-first (with optional Python helper)

## Overview
This repository provides a **Terraform-first** implementation to manage GitHub Organization settings (teams, repos, branch protections, labels) and a **small optional Python helper** for label sync or post-Terraform fixes.

Contents:
- `providers.tf`, `backend.tf`, `variables.tf`, `outputs.tf` — Root terraform files
- `modules/` — Terraform modules: teams, repos, branch_protection, labels
- `envs/prod/` — Composition that calls modules (example)
- `cloudbuild.yaml` — GCP Cloud Build pipeline to run terraform
- `optional_helpers/sync_labels.py` — Optional Python helper (uses PyGithub)
- `runbook.md` — Runbook: onboarding, token rotation, TF state, permissions

## Quick start (local)
1. Install Terraform >= 1.4.0
2. Create a GCS bucket for TF state (if using GCS backend) and set `tfstate_bucket` var.
3. Export `GITHUB_TOKEN` env var with an admin token (or use Secret Manager in Cloud Build).
4. `cd envs/prod && terraform init && terraform plan`

## Cloud Build
- Store your GitHub token in Secret Manager under `github-token`
- Create a Cloud Build trigger that runs `cloudbuild.yaml` on changes to the infra branch
- To apply automatically, set substitution `_TF_APPLY=true` in build trigger (only for trusted branches)

## Optional Python helper
The `optional_helpers/sync_labels.py` script shows how to sync labels across repos. It is optional — Terraform manages labels as primary.

## Security notes
- Do NOT commit GitHub tokens to the repo.
- Use Secret Manager and restrict access by IAM to Cloud Build SA and infra owners.
- Rotate tokens regularly.
