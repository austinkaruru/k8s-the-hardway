terraform {
    required_providers {
        google = {
            source  = "hashicorp/google"
            version = "6.47.0"
        }
    }
    backend "gcs" {
        bucket  = "kthw-tf-state"
        prefix  = "terraform/state"
      
    }
}

provider "google" {
  project     = var.project_id
  region      = var.region
  zone        = var.zone
  credentials = var.google_credentials
}
