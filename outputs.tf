output "vm_ips" {
  description = "The external IP address of the VM instance."
  value = {
    for k, mod in module.gce :
    k => mod.vm_ip
  }
}

output "vm_instance_names" {
  description = "The names of the VM instances."
  value = {
    for k, mod in module.gce :
    k => mod.vm_instance_name
  }
}


output "vm_instance_machine_types" {
  description = "Machine types for the VMs"
  value = {
    for k, mod in module.gce :
    k => mod.vm_instance_machine_type
  }
}
