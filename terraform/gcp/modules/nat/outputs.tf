output "router_name" {
  value = google_compute_router.nat_router.name
}

output "nat_name" {
  value = google_compute_router_nat.nat.name
}
