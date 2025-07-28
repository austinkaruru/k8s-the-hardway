variable "project_id" {}
variable "region" {}
variable "zone" {}
variable "jumpbox_name" {}
variable "machine_type" {}
variable "image" {}
variable "network_name" {}
variable "google_credentials" {
    type = string
    description = "Path to the Google Cloud service account credentials JSON file."
    sensitive = true
}