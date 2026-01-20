# Cloud Router for NAT (regional)
resource "google_compute_router" "nat_router" {
  name    = var.router_name
  region  = var.region
  network = var.network_self_link
}

# Cloud NAT: egress for private subnet (back) without public IP
resource "google_compute_router_nat" "nat" {
  name   = var.nat_name
  router = google_compute_router.nat_router.name
  region = var.region
  # Allow Cloud NAT to automatically manage external IPs
  nat_ip_allocate_option = "AUTO_ONLY"
  # Restrict NAT to the explicitly listed subnet ranges
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  # Configure NAT for the private subnet across all its IP ranges
  subnetwork {
    name = var.private_subnet_self_link
    # Allow Cloud NAT to translate every primary and secondary IP range of this subnet to the managed external addresses
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  # Log only Cloud NAT errors; switch to ALL when detailed debugging is required
  log_config {
    # Enable Cloud NAT log export
    enable = true
    # Keep logs concise by capturing only error-level events
    filter = "ERRORS_ONLY"
  }
}
