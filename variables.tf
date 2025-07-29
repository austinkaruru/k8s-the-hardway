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
    name          = string
    machine_type  = string
    disk_size_gb  = number
  }))
  default = {
    jumpbox = {
      name         = "jumpbox"
      machine_type = "e2-micro"
      disk_size_gb = 10
    },
    server = {
      name         = "server"
      machine_type = "e2-small"
      disk_size_gb = 20
    },
    node-0 = {
      name         = "node-0"
      machine_type = "e2-medium"
      disk_size_gb = 20
    },
    node-1 = {
      name         = "node-1"
      machine_type = "e2-medium"
      disk_size_gb = 20
    }
  }
}

variable "network_name" {
  description = "The name of the network to create."
}
variable "google_credentials" {
  type        = string
  description = "Path to the Google Cloud service account credentials JSON file."
  sensitive   = true
  default     = "credentials/k8s-tf.json"
}

variable "sa_account" {
  description = "The service account to use for the Google Cloud resources."
  type        = string
}
