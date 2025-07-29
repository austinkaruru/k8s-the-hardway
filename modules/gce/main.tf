resource "google_compute_address" "vm_ip" {
  name   = "${var.node_name}-ip"
  region = var.region
}

resource "google_compute_disk" "vm_disk" {
  name  = "${var.node_name}-disk"
  type  = "pd-standard"
  image = var.debian
  zone  = var.zone
  size = var.size
}

resource "google_compute_instance" "vm" {
  name         = var.node_name
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["k8s-thw"]
  allow_stopping_for_update = true

  boot_disk {
    source      = google_compute_disk.vm_disk.id
    auto_delete = true
  }

  network_interface {
    network = var.network_name
    access_config {
      nat_ip = google_compute_address.vm_ip.address
    }
  }

  service_account {
    email  = var.tf_sa
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}