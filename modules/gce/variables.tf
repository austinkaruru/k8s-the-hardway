variable "node_name" {
  description = "The names of the VM instances."
}

variable "region" {
  description = "The Google Cloud region where resources will be created."
  default     = "europe-west4"
}
variable "zone" {
  description = "The Google Cloud zone where resources will be created."
  default     = "europe-west4-a"
}

variable "image_type" {
  description = "The image type to use for the VM instances."
  type        = string
  
}

variable "machine_type" {
  description = "The machine type for the instances."
}

variable "boot_disk" {
  description = "The type of boot disk for the VM instances."
  type        = string
}

variable "network_name" {
  description = "The name of the network to create."
  type        = string
}

variable "tf_sa" {
  description = "The service account to use for the Google Cloud resources."
  type        = string
}

variable "size" {
  description = "The size of the disk for the VM instances in GB."
  type        = number
}

variable "tags" {
  description = "Network tags for the VM instances."
  type        = list(string)
  default     = ["k8s-thw"]
  
}

variable ssh_key {
  description = "Path to the SSH public key file."
  type        = string
}

variable ssh_username {
  description = "The username for SSH access to the VM instances."
  type        = string
}