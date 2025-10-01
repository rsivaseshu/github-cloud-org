# Runbook: GitHub Org As Code (Terraform-first)

## Onboarding
1. SSO-first approach: Map IdP groups to GitHub teams.
2. Use Terraform for service accounts and infra-only users.
3. Keep human membership in IdP where possible to avoid dual-sources.

## Token rotation
- Store the token in GCP Secret Manager: `gcloud secrets create github-token --data-file=-`
- Update secret and redeploy Cloud Build trigger when rotating.

## Terraform state
- GCS backend configured in `backend.tf`
- Ensure the Cloud Build SA has `storage.objectAdmin` on the bucket
- Enable versioning on the bucket for state recovery

## Rollback
- Use `terraform plan` output to inspect changes.
- To rollback, revert the infra repo to the previous commit and run a plan/apply.

## Troubleshooting
- Provider errors: check provider version. Update `required_providers` if needed.
- 403/permissions: ensure token scopes `admin:org, repo, admin:org_hook`.
