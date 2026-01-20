output "manager_instance_name" {
  value = google_compute_instance.manager.name
}

output "bastion_instance_name" {
  value = google_compute_instance.bastion.name
}

output "monitoring_instance_name" {
  value = google_compute_instance.monitoring.name
}

output "worker_instance_names" {
  value = [for w in google_compute_instance.worker : w.name]
}

output "manager_instance_ip" {
  value = var.manager_static_ip
}

output "bastion_instance_ip" {
  value = var.bastion_static_ip
}

output "monitoring_instance_ip" {
  value = var.monitoring_static_ip
}

output "worker_instance_ips" {
  value = { for k, v in google_compute_instance.worker : k => v.network_interface[0].network_ip }
}
