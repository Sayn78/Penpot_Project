output "network_name" {
  value = google_compute_network.primary.name
}

output "network_self_link" {
  value = google_compute_network.primary.self_link
}

output "network_id" {
  value = google_compute_network.primary.id
}

output "subnet_private" {
  value = google_compute_subnetwork.private
}

output "subnet_public" {
  value = google_compute_subnetwork.public
}

output "subnet_db" {
  value = google_compute_subnetwork.database
}
