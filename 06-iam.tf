## Create Service Account for IAP access
resource "google_service_account" "terraform_demo" {
  project      = var.gcp_project
  account_id   = "terraform-demo-aft"
  display_name = "Terraform Demo Service Account"
  
  depends_on = [local.api_dependency]
}

## Create IAP SSH permissions for your test instance
resource "google_project_iam_member" "project" {
  project = var.gcp_project
  role    = "roles/iap.tunnelResourceAccessor"
  member  = "serviceAccount:${google_service_account.terraform_demo.email}"
  
  depends_on = [google_service_account.terraform_demo]
}
