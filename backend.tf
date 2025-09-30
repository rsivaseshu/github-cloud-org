terraform {
  backend "gcs" {
    bucket = var.tfstate_bucket
    prefix = "github-org/terraform-state"
  }
}
