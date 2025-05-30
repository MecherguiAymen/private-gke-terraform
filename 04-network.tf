# create VPC
resource "google_compute_network" "vpc" {
  project                 = var.gcp_project
  name                    = "vpc1"
  auto_create_subnetworks = false
  
  depends_on = [local.api_dependency]
}

# Create Subnet
resource "google_compute_subnetwork" "subnet" {
  project       = var.gcp_project
  name          = "subnet1"
  region        = var.gcp_region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.0.0.0/24"
}

# create cloud router for nat gateway
resource "google_compute_router" "router" {
  project = var.gcp_project
  name    = "nat-router"
  network = google_compute_network.vpc.name
  region  = var.gcp_region
  
  depends_on = [google_compute_network.vpc, local.api_dependency]
}

## Create Nat Gateway with module
module "cloud-nat" {
  source     = "terraform-google-modules/cloud-nat/google"
  version    = "~> 1.2"
  project_id = var.gcp_project
  region     = var.gcp_region
  router     = google_compute_router.router.name
  name       = "nat-config"
}

## Create Firewall to access jump host via iap
resource "google_compute_firewall" "rules" {
  project = var.gcp_project
  name    = "allow-ssh"
  network = google_compute_network.vpc.name
  
  depends_on = [google_compute_network.vpc, local.api_dependency]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["35.235.240.0/20"]
}
