provider "google" {
  project     = var.project_id
  region      = var.region
  zone        = var.zone
  credentials = var.google_credentials
}

resource "google_compute_project_metadata" "my_ssh_key" {
  metadata = {
    ssh-keys = "${var.ssh_username}:${file(var.ssh_key)}"
  }
}
resource "google_compute_address" "jumpbox_ip" {
  name   = "${var.jumpbox_name}-ip"
  region = var.region
}

data "google_compute_image" "debian" {
  family  = "debian-12"
  project = "debian-cloud"
}

data "google_service_account" "tf_sa" {
  account_id = var.sa_account
}
resource "google_compute_network" "tf_network" {
  name                    = var.network_name
  auto_create_subnetworks = true

}

resource "google_compute_firewall" "k8s_firewall" {
  name    = "${var.network_name}-firewall"
  network = google_compute_network.tf_network.id
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }
  target_tags   = ["k8s-thw"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_disk" "jumpbox_disk" {
  name  = "${var.jumpbox_name}-disk"
  type  = "pd-standard"
  image = data.google_compute_image.debian.self_link
  zone  = var.zone
  size  = 10
}
resource "google_compute_instance" "jumpbox" {
  name                      = var.jumpbox_name
  machine_type              = var.machine_type
  zone                      = var.zone
  tags                      = ["k8s-thw"]
  allow_stopping_for_update = true
  boot_disk {
    source      = google_compute_disk.jumpbox_disk.id
    auto_delete = true
  }

  network_interface {
    network = google_compute_network.tf_network.id
    access_config {
      nat_ip = google_compute_address.jumpbox_ip.address
    }
  }
  service_account {
    email  = data.google_service_account.tf_sa.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

}

output "jumpbox_ip" {
  value = google_compute_address.jumpbox_ip.address
}

output "tf_sa_account" {
  value = data.google_service_account.tf_sa.email
}