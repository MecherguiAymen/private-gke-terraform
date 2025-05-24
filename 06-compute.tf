## Create jump host internal IP
resource "google_compute_address" "my_internal_ip_addr" {
  project      = var.gcp_project
  address_type = "INTERNAL"
  region       = var.gcp_region1
  subnetwork   = google_compute_subnetwork.subnet.name
  name         = "my-ip"
  address      = "10.0.0.7"
  description  = "An internal IP address for my jump host"
  
  depends_on = [google_compute_subnetwork.subnet, local.api_dependency]
}

## Create jump host instance
resource "google_compute_instance" "default" {
  project      = var.gcp_project
  zone         = var.gcp_region
  name         = "jump-host"
  machine_type = "e2-medium"
  
  depends_on = [google_compute_address.my_internal_ip_addr, local.api_dependency]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network    = google_compute_network.vpc.name
    subnetwork = google_compute_subnetwork.subnet.name
    network_ip = google_compute_address.my_internal_ip_addr.address
  }
}
