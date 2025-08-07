provider "google" {
  project     = var.project_id
  region      = var.region
  zone        = var.zone
  credentials = var.google_credentials
}

data "google_service_account" "tf_sa" {
  account_id = var.sa_account
}

data "google_compute_image" "image_type" {
  family  = "debian-12"
  project = "debian-cloud"
}

module "net" {
  source = "./modules/net"

  network_name           = var.vpc_name
  firewall_protocols     = var.firewall_protocols
  firewall_ports         = var.firewall_ports
  firewall_target_tags   = var.firewall_target_tags
  firewall_source_ranges = var.firewall_source_ranges

}

module "gce" {
  source   = "./modules/gce"
  for_each = var.vms

  node_name    = each.value.name
  region       = var.region
  zone         = var.zone
  image_type   = data.google_compute_image.image_type.self_link
  machine_type = each.value.machine_type
  boot_disk    = var.boot_disk
  tags         = var.gce_tags
  network_name = module.net.vpc_network_name
  tf_sa        = data.google_service_account.tf_sa.email
  size         = each.value.disk_size_gb
  ssh_username = var.ssh_username
  ssh_key      = var.ssh_key

}
