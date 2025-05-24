# Enable required Google Cloud APIs
# Service Usage API must be enabled first
resource "google_project_service" "serviceusage" {
  project = var.gcp_project
  service = "serviceusage.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_project_service" "compute" {
  project = var.gcp_project
  service = "compute.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
  depends_on = [google_project_service.serviceusage]
}

resource "google_project_service" "container" {
  project = var.gcp_project
  service = "container.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
  depends_on = [google_project_service.serviceusage]
}

resource "google_project_service" "iap" {
  project = var.gcp_project
  service = "iap.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
  depends_on = [google_project_service.serviceusage]
}

# Add dependencies to ensure APIs are enabled before resources are created
locals {
  api_dependency = [
    google_project_service.serviceusage.id,
    google_project_service.compute.id,
    google_project_service.container.id,
    google_project_service.iap.id
  ]
}
