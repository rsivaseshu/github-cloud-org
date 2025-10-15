# GitHub Cloud Organization Automation (Managed from GCP)

## 📘 Overview

This repository automates the configuration, policy enforcement, and lifecycle management of our **GitHub Enterprise Cloud organization**, using **Google Cloud Platform (GCP)** as the automation backbone.

We manage all GitHub org and repo settings as **code**, including:

- Organization-level general and access settings  
- Repository creation, policies, and branch protection  
- Code / planning / automation configuration  
- Security controls and secrets  
- Third-party integrations  
- Developer settings and role management  

All automation runs from **Google Cloud Build**, uses **Terraform** for declarative infrastructure, **Safe-Settings** for policy enforcement, and **Google Cloud Identity (SAML + SCIM)** for identity and access automation.

---

## 🧩 Architecture

### Core Components

| Function | Tool | Description |
|-----------|------|-------------|
| **Source of truth** | Terraform (GitHub provider) | Declaratively manages org, repos, teams, and policies |
| **Policy enforcement** | Safe-Settings (GitHub App) | Applies and enforces repo-level policies via YAML |
| **CI/CD orchestration** | Cloud Build | Executes Terraform plans/applies and validation |
| **Secrets management** | Google Secret Manager | Centralized secure secrets storage |
| **Identity & access** | Google Cloud Identity (SAML + SCIM) | Automates user and team provisioning |
| **Scripting / Glue** | `gh` CLI / Octokit | For non-Terraform API coverage and one-off tasks |

---

## ⚙️ Section-by-Section Automation

### 1. General Organization Settings
- Managed through **Terraform** (org/repo defaults, visibility, templates).
- Use **Safe-Settings** for enforcing default branch rules, merge policies, and repository naming conventions.

> 🧠 State backend: GCS bucket (`gs://org-terraform-state`)

---

### 2. Policies
- Store branch protection, review rules, and PR checks in `terraform/`.
- Safe-Settings YAML (in `policies/`) auto-applies required rules on new repos.

```bash
terraform apply -var "org_name=my-org"

## 3. Access (RBAC)

- Managed via **Google Cloud Identity** → **GitHub SCIM**.
- Group-to-team mapping ensures consistent permissions.
- **Terraform** controls team structure and permissions where applicable.
- 🔐 **SCIM** handles provisioning and deprovisioning automatically.

## 4. Code, Planning, and Automation

- **Cloud Build** triggers pipelines for CI/CD and Terraform automation.
- **GitHub Actions** can be used for lightweight PR checks (lint, tests).

**Example Cloud Build trigger workflow:**
```yaml
steps:
    - name: 'hashicorp/terraform'
        args: ['init']
    - name: 'hashicorp/terraform'
        args: ['plan', '-out=plan.tfplan']
```

## 5. Security and Compliance

- Secrets stored in **Google Secret Manager**.
- Code scanning via **Dependabot**, **CodeQL**, and **SAST** runs in Cloud Build or Actions.
- GitHub audit logs exported to SIEM.
- Enforce least privilege via GitHub Apps and GCP IAM service accounts.
- 🔒 Only Cloud Build service accounts and GitHub Apps have PATs/secrets access.

## 6. Third-Party Apps and Integrations

- Maintain a `trusted_apps.yaml` list in this repo.
- Approved apps installed via **Terraform** or **Octokit** scripts.
- Restrict app installation to org admins only.

## 7. Developer Settings

- Controlled by org-level policies (**Safe-Settings** + **Terraform**).
- Restrict personal access tokens and Actions permissions.
- Developer sandboxes available in isolated repos.

---

## ☁️ GCP Integration

| GCP Service         | Purpose                                         |
|---------------------|------------------------------------------------|
| Cloud Build         | CI/CD runner for Terraform, lint, and policy enforcement |
| GCS                 | Terraform backend for state storage            |
| Secret Manager      | Secure secret management for automation        |
| Cloud Logging / SCC | Centralized logs and security visibility       |
| Cloud Identity      | User and team provisioning into GitHub         |

---

## 🧠 Workflow Summary

- PR created → Cloud Build runs terraform plan
- Review & merge → Cloud Build runs terraform apply
- Safe-Settings continuously enforces repo-level defaults
- SCIM + SAML keep user/team access synced automatically
- Drift detection jobs compare API → Terraform state weekly

---

## 🚀 Setup Steps

### 1. Export current org settings
```bash
gh api /orgs/<org_name>/repos > inventory/repos.json
```

### 2. Configure GCP backend
```hcl
terraform {
    backend "gcs" {
        bucket = "org-terraform-state"
        prefix = "github"
    }
}
```

### 3. Connect Cloud Build

- Create a Cloud Build trigger for this repo.
- Add GitHub connection via Cloud Build GitHub App.
- Grant Cloud Build service account permission to access GCS and Secret Manager.

### 4. Secrets setup

- Store GitHub PAT or App token in **Google Secret Manager**.
- Access using `google-github-actions/get-secretmanager-secrets` or Cloud Build IAM roles.

### 5. Enable SSO and SCIM

- Connect GitHub Enterprise Cloud to Google Workspace / Cloud Identity.
- Enable SAML for authentication and SCIM for automatic provisioning.

### 6. Deploy Safe-Settings

- Install the Safe-Settings GitHub App.
- Add `policies/settings.yml` to define repo defaults.

---

## 📄 Repository Structure

```
github-org-automation/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   └── github_repos.tf
├── policies/
│   └── settings.yml
├── scripts/
│   └── export_org_inventory.sh
├── cloudbuild.yaml
└── README.md
```

---

## 🔁 Drift Detection (Recommended)

- Schedule Cloud Build job or GitHub Action weekly:
    ```bash
    terraform plan -detailed-exitcode
    ```
- Exit code 2 = drift detected → notify Slack/Teams.

---

## 🧰 Useful Tools

| Tool                    | Purpose                          |
|-------------------------|----------------------------------|
| gh CLI                  | Quick org/repo automation        |
| Octokit                 | API scripting                    |
| Terraform GitHub Provider| Declarative org & repo management|
| Safe-Settings App       | Policy-as-code enforcement       |
| Google Secret Manager   | Centralized secret store         |
| Cloud Build             | CI/CD automation engine          |
