variable "jumpbox_name" {
  description = "The name of the jumpbox instance."
  default     = "jumpbox"
}

variable "region" {
  description = "The Google Cloud region where resources will be created."
  default     = "europe-west4"
}
variable "zone" {
  description = "The Google Cloud zone where resources will be created."
  default     = "europe-west4-a"
}

variable "machine_type" {
  description = "The machine type for the instances."
  default     = "e2-medium"
}

variable "network_name" {
  description = "The name of the network to create."
  type        = string
}

variable "tf_sa" {
  description = "The service account to use for the Google Cloud resources."
  type        = string
}

