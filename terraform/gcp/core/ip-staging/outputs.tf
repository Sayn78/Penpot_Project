output "manager_ip_staging" {
  value = google_compute_address.manager_staging.address
}

output "bastion_ip_staging" {
  value = google_compute_address.bastion_staging.address
}

output "monitoring_ip_staging" {
  value = google_compute_address.monitoring_staging.address
}
