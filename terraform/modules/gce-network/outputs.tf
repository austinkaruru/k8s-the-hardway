output "vpc_network_name" {
    value = google_compute_network.vpc_network.name
}

output "management_subnet_name" {
  value = google_compute_subnetwork.management_subnet.name
}

output "node_0_subnet_name" {
  value = google_compute_subnetwork.node_0_subnet.name
}

output "node_1_subnet_name" {
  value = google_compute_subnetwork.node_1_subnet.name
}

