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

data "google_service_account" "tf_sa" {
  account_id = var.sa_account
}

data "google_compute_image" "debian" {
  family  = "debian-11"
  project = "debian-cloud"
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



module "gce" {
  source = "./modules/gce"
  for_each = var.vms

  node_name = each.value.name
  region = var.region
  zone = var.zone
  debian = data.google_compute_image.debian.self_link
  machine_type = each.value.machine_type
  network_name = var.network_name
  tf_sa = data.google_service_account.tf_sa.email
  size = each.value.disk_size_gb

}
