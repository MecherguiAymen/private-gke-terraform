# Random DB Name suffix
resource "random_id" "db_name_suffix" {
  byte_length = 4
}

# Le sous-réseau dédié a été retiré pour simplifier la configuration

# Allocation d'une plage d'adresses IP privées pour Cloud SQL
resource "google_compute_global_address" "private_ip_address" {
  project       = var.gcp_project
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 24
  network       = google_compute_network.vpc.id
}

# Crée une connexion privée VPC pour Cloud SQL
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
  
  depends_on = [google_project_service.servicenetworking]
}

# Resource: Cloud SQL Database Instance
resource "google_sql_database_instance" "mydbinstance" {
  # Create DB only after Private VPC connection is created and API enabled
  depends_on = [
    google_service_networking_connection.private_vpc_connection,
    google_project_service.sqladmin
  ]
  name = "mysql-${random_id.db_name_suffix.hex}"
  database_version = "MYSQL_8_0"
  project = var.gcp_project
  deletion_protection = false
  region = var.gcp_region
  
  settings {
    tier    = "db-f1-micro"
    edition = "ENTERPRISE"
    availability_type = "ZONAL"
    disk_autoresize = true
    disk_autoresize_limit = 20
    disk_size = 10
    disk_type = "PD_SSD"
    
    backup_configuration {
      enabled = true
      binary_log_enabled = true
    }
    
    ip_configuration {
      ipv4_enabled = false
      private_network = google_compute_network.vpc.id
      # On ne spécifie pas de sous-réseau car Cloud SQL utilise la plage réservée via Service Networking
    }
  }
}

# Resource: Cloud SQL Database Schema
resource "google_sql_database" "mydbschema" {
  name     = "db-cafe-managment"
  instance = google_sql_database_instance.mydbinstance.name
}

# Resource: Cloud SQL Database User
resource "google_sql_user" "users" {
  name     = "umsadmin"
  instance = google_sql_database_instance.mydbinstance.name
  host     = "%"
  password = "dbpassword11"
}

# Outputs
output "cloudsql_db_private_ip" {
  value = google_sql_database_instance.mydbinstance.private_ip_address
}

output "mydb_schema" {
  value = google_sql_database.mydbschema.name
}

output "mydb_user" {
  value = google_sql_user.users.name
}

output "mydb_password" {
  value = google_sql_user.users.password
  sensitive = true
}

# Informations sur le réseau - sous-réseau dédié supprimé

output "sql_reserved_range" {
  value = "${google_compute_global_address.private_ip_address.address}/${google_compute_global_address.private_ip_address.prefix_length}"
}
