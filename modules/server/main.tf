resource "google_compute_address" "server_ip" {
  name   = "${var.server_name}-ip"
  region = var.region
}

resource "google_compute_disk" "server_disk" {
  name  = "${var.server_name}-disk"
  type  = "pd-standard"
  image = var.debian
  zone  = var.zone
  size  = 20
}

resource "google_compute_instance" "server" {
  name                      = var.server_name
  machine_type              = var.server_machine_type
  zone                      = var.zone
  tags                      = ["k8s-thw"]
  allow_stopping_for_update = true
  boot_disk {
    source      = google_compute_disk.server_disk.id
    auto_delete = true
  }

  network_interface {
    network = var.network_name
    access_config {
      nat_ip = google_compute_address.server_ip.address
    }
  }
  service_account {
    email = var.tf_sa
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}
