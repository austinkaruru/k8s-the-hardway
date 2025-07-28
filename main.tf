provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
  credentials = var.google_credentials
}

resource "google_compute_network" "tf_network" {
  name                    = var.network_name
  auto_create_subnetworks = true
}

resource "google_compute_instance" "jumpbox" {
  name         = var.jumpbox_name
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    network = google_compute_network.tf_network.id
    access_config {

    }
  }
}