variable "network_name" {
  description = "The name of the network to create."
  type = string
}

variable "firewall_protocols" {
    description = "Protocols and ports to allow in the firewall rules."
    type = string
    }

variable "firewall_ports" {
    description = "List of ports to allow in the firewall rules."
    type = list(string)
}

variable "firewall_target_tags" {
    description = "Target tags for the firewall rules."
    type = list(string)
}

variable "firewall_source_ranges" {
  description = "Source ranges for the firewall rules."
  type = list(string)
}

variable "region" {
  description = "The Google Cloud region where resources will be created."
  default     = "europe-west4"

}

variable "zone" {
  description = "The Google Cloud zone where resources will be created."
  default     = "europe-west4-a"  
  
}
