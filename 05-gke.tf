# Create GKE cluster with 2 nodes in our custom VPC/Subnet
resource "google_container_cluster" "primary" {
  project                  = var.gcp_project
  name                     = "my-gke-cluster"
  location                 = var.gcp_region
  network                  = google_compute_network.vpc.name
  subnetwork               = google_compute_subnetwork.subnet.name
  remove_default_node_pool = true ## create the smallest possible default node pool and immediately delete it.
  initial_node_count       = 1
  deletion_protection      = false
  
  depends_on = [google_compute_subnetwork.subnet, local.api_dependency]

  private_cluster_config {
    enable_private_endpoint = true
    enable_private_nodes    = true
    master_ipv4_cidr_block  = "10.13.0.0/28"
  }
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "10.11.0.0/21"
    services_ipv4_cidr_block = "10.12.0.0/21"
  }
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "10.0.0.7/32"
      display_name = "net1"
    }
  }
}

# Create managed node pool
resource "google_container_node_pool" "primary_nodes" {
  project    = var.gcp_project
  name       = google_container_cluster.primary.name
  location   = var.gcp_region
  cluster    = google_container_cluster.primary.name
  node_count = 3

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = "dev"
    }

    machine_type = "n1-standard-1"
    preemptible  = true

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}
