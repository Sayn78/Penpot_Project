# VPC with custom subnets. No auto subnets; regional routing.
resource "google_compute_network" "primary" {
  name = var.network_name
  # Disable auto-created subnets to keep only the custom ones
  auto_create_subnetworks = false
  # Force regional routing so each region keeps its own traffic
  routing_mode = "REGIONAL"
}

# Private subnet: back + PSA consumers (Cloud SQL/Redis), no public IPs.
resource "google_compute_subnetwork" "private" {
  name          = var.subnet_private_name
  ip_cidr_range = var.subnet_private_cidr
  region        = var.region
  network       = google_compute_network.primary.self_link
  # Allow subnet VMs to reach Google APIs privately without public IPs
  private_ip_google_access = var.subnet_private_private_google_access
}

# Public subnet: front, bastion, monitoring (these have public IPs).
resource "google_compute_subnetwork" "public" {
  name          = var.subnet_public_name
  ip_cidr_range = var.subnet_public_cidr
  region        = var.region
  network       = google_compute_network.primary.self_link
  # Optional; typically false here because these VMs use their public IP for Google APIs.
  private_ip_google_access = var.subnet_public_private_google_access
}

# Dedicated subnet for PSA (Cloud SQL/Redis).
resource "google_compute_subnetwork" "database" {
  name          = var.subnet_db_name
  ip_cidr_range = var.subnet_db_cidr
  region        = var.region
  network       = google_compute_network.primary.self_link
  # Allow subnet VMs to reach Google APIs privately without public IPs
  private_ip_google_access = true
  # Flags this subnet as the Private Service Access landing zone so Cloud SQL, Memorystore, and other PSA services reserve their internal IPs here.
  purpose = "PRIVATE"
  role    = "ACTIVE"
}

# PSA allocated range (/22) for Cloud SQL + Redis.
resource "google_compute_global_address" "private_service_access" {
  name = "${var.network_name}-psa-range"
  # Reserve this range strictly for Private Service Access peering (Cloud SQL, Memorystore).
  purpose = "VPC_PEERING"
  # Allocate an internal-only address block for the PSA peering.
  address_type = "INTERNAL"
  network      = google_compute_network.primary.self_link
  # Let Google allocate the starting IP automatically while honoring the /22 size.
  address = null
  # Size the PSA range as /22 to offer ~1024 internal IPs for managed services.
  prefix_length = 22

  description = "Allocated range for Private Service Access (Cloud SQL, Redis)"
}

# Service Networking peering for private services (Cloud SQL/Redis). ABANDON prevents destroy failures.
resource "google_service_networking_connection" "psa" {
  network = google_compute_network.primary.self_link
  # Attach the VPC to Google managed services via the Service Networking API (Cloud SQL, Memorystore).
  service = "servicenetworking.googleapis.com"
  # Bind the Service Networking peering to the dedicated /22 PSA range reserved above.
  reserved_peering_ranges = [google_compute_global_address.private_service_access.name]
  # Avoid destroy failures when Cloud SQL has used the PSA; ABANDON lets destroy proceed, manual cleanup may be needed.
  deletion_policy = "ABANDON"
}
