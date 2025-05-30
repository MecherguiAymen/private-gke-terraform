
# 1. IP statique réservée - Utilisation d'une adresse IP spécifique existante
resource "google_compute_address" "frontend_ip" {
  project      = var.gcp_project
  name         = "social-login-static-ip"
  region       = var.gcp_region
  address      = "34.116.249.163"  # Spécification de l'adresse IP statique
  address_type = "EXTERNAL"         # IP externe accessible publiquement
}

# 2. Zone DNS gérée
resource "google_dns_managed_zone" "frontend_zone" {
  project     = var.gcp_project
  name        = "frontend-zone"
  dns_name    = "pfe.com."  # Remplacez par votre nom de domaine réel
  description = "Zone DNS pour l'application Café Management"
  
  # Configuration de visibilité publique pour s'assurer que le DNS est accessible publiquement
  visibility = "public"
  
  # Configuration DNSSEC optionnelle pour plus de sécurité
  dnssec_config {
    state = "on"
    default_key_specs {
      algorithm  = "rsasha256"
      key_length = 2048
      key_type   = "keySigning"
    }
    default_key_specs {
      algorithm  = "rsasha256"
      key_length = 1024
      key_type   = "zoneSigning"
    }
  }
}

# 3. Enregistrement DNS (A record)
resource "google_dns_record_set" "frontend_dns" {
  project      = var.gcp_project
  name         = "cafe.management.pfe.com."  # Le sous-domaine que vous voulez utiliser
  managed_zone = google_dns_managed_zone.frontend_zone.name
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_address.frontend_ip.address]
}

# Outputs pour faciliter l'accès aux informations
output "frontend_static_ip" {
  description = "Adresse IP statique pour le frontend"
  value       = google_compute_address.frontend_ip.address
}

output "frontend_domain" {
  description = "Nom de domaine complet pour accéder à l'application"
  value       = google_dns_record_set.frontend_dns.name
}

# Serveurs de noms pour configurer le domaine
output "name_servers" {
  description = "Serveurs de noms pour configurer le domaine chez le registraire"
  value       = google_dns_managed_zone.frontend_zone.name_servers
}

# Instructions pour configurer le domaine
output "dns_setup_instructions" {
  description = "Instructions pour configurer le domaine"
  value       = "Pour configurer votre domaine, rendez-vous chez votre registraire de domaine et configurez les serveurs de noms listés dans l'output 'name_servers'."
}
