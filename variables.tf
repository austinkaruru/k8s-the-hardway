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
variable "jumpbox_name" {
  description = "The name of the jumpbox instance."
  default     = "jumpbox"
}
variable "machine_type" {
  description = "The machine type for the instances."
  default     = "e2-medium"
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