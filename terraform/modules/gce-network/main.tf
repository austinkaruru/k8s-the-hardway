resource "google_compute_network" "vpc_network" {
  name                    = var.network_name
  auto_create_subnetworks = false

}

# Management subnet for jumpbox and server (control plane)
resource "google_compute_subnetwork" "management_subnet" {
  name          = "${var.network_name}-management"
  ip_cidr_range = "10.240.0.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

# Node-0 subnet (matches its pod CIDR for simplicity)
resource "google_compute_subnetwork" "node_0_subnet" {
  name          = "${var.network_name}-node-0"
  ip_cidr_range = "10.200.0.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

# Node-1 subnet (matches its pod CIDR for simplicity)
resource "google_compute_subnetwork" "node_1_subnet" {
  name          = "${var.network_name}-node-1"
  ip_cidr_range = "10.200.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

# Allow all internal communication between subnets
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.network_name}-allow-internal"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.240.0.0/24", "10.200.0.0/24", "10.200.1.0/24"]
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


