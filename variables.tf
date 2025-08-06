variable "project_id" {
  description = "The Google Cloud project ID where resources will be created."
  type        = string
}

variable "ssh_key" {
  description = "Path to the SSH public key file to be added to the project metadata."
  type        = string
  sensitive   = true
}

variable "ssh_username" {
  description = "The username for the SSH key."
  type        = string
}

variable "gce_tags" {
  description = "Tags to apply to the GCE instances."
  type        = list(string)
}
variable "boot_disk" {
  description = "The type of boot disk for the VM instances."
  type        = string
}

variable "region" {
  description = "The Google Cloud region where resources will be created."
  default     = "europe-west4"
}
variable "zone" {
  description = "The Google Cloud zone where resources will be created."
  default     = "europe-west4-a"
}
variable "vms" {
  description = "VM configurations (name, machine type, disk size)"
  type = map(object({
    name         = string
    machine_type = string
    disk_size_gb = number
  }))
}

variable "firewall_protocols" {
  description = "Protocols to allow in the firewall rules."
  type        = string
}

variable "firewall_ports" {
  description = "List of ports to allow in the firewall rules."
  type        = list(string)

}

variable "firewall_target_tags" {
  description = "Target tags for the firewall rules."
  type        = list(string)
}
variable "firewall_source_ranges" {
  description = "Source ranges for the firewall rules."
  type        = list(string)
}

variable "vpc_name" {
  description = "The name of the network to create."
  type        = string
}

variable "google_credentials" {
  type        = string
  description = "Path to the Google Cloud service account credentials JSON file."
  sensitive   = true
}

variable "sa_account" {
  description = "The service account to use for the Google Cloud resources."
  type        = string
}
