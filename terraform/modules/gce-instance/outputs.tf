output "vm_ip" {
  value = google_compute_instance.vm.network_interface[0].access_config[0].nat_ip
}

output "vm_instance_name" {
  value = google_compute_instance.vm.name
}


output "vm_instance_machine_type" {
  value = google_compute_instance.vm.machine_type
}

