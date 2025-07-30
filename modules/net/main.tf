resource "google_compute_network" "vpc_network" {
  name                    = var.network_name
  auto_create_subnetworks = true

}

resource "google_compute_firewall" "k8s_firewall" {
  name    = "${var.network_name}-firewall"
  network = google_compute_network.vpc_network.id
  allow {
    protocol = var.firewall_protocols
    ports    = var.firewall_ports
  }
  target_tags   = var.firewall_target_tags
  source_ranges = var.firewall_source_ranges
}

