resource "google_compute_address" "jumpbox_ip" {
  name   = "${var.jumpbox_name}-ip"
  region = var.region
}


resource "google_compute_disk" "jumpbox_disk" {
  name  = "${var.jumpbox_name}-disk"
  type  = "pd-standard"
  image = var.debian
  zone  = var.zone
  size  = 10
}

resource "google_compute_instance" "jumpbox" {
  name                      = var.jumpbox_name
  machine_type              = var.jumpbox_machine_type
  zone                      = var.zone
  tags                      = ["k8s-thw"]
  allow_stopping_for_update = true
  boot_disk {
    source      = google_compute_disk.jumpbox_disk.id
    auto_delete = true
  }

  network_interface {
    network = var.network_name
    access_config {
      nat_ip = google_compute_address.jumpbox_ip.address
    }
  }
  service_account {
    email  = var.tf_sa
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

}