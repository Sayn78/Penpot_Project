output "manager_ip_prod" {
  value = google_compute_address.manager_prod.address
}

output "bastion_ip_prod" {
  value = google_compute_address.bastion_prod.address
}

output "monitoring_ip_prod" {
  value = google_compute_address.monitoring_prod.address
}
