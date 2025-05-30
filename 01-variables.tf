# GCP Project
variable "gcp_project" {
  description = "Project in which GCP Resources to be created"
  type        = string
  default     = "sbx-31371-bwbugg8hgxy7gsijq0t9"
}

# GCP Region
variable "gcp_zone" {
  description = "Region in which GCP Resources to be created"
  type        = string
  default     = "europe-central2-a"
}

# artifacr registry and cloud run region
variable "gcp_region" {
  description = "Region in which GCP resource will be created"
  type        = string
  default     = "europe-central2"
}
