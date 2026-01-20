# Reserve stable external IPs for PROD (manager, bastion, monitoring).
# Kept in its own state/bucket to avoid DNS changes and allow independent teardown.
resource "google_compute_address" "manager_prod" {
  name        = "penpot-prod-manager-ip"
  region      = var.region
  description = "Static external IP for manager (prod)"
  lifecycle {
    prevent_destroy = true
  }
}

# Bastion public IP (SSH entry point for prod, OS Login only). No other VM has a public IP in prod.
resource "google_compute_address" "bastion_prod" {
  name        = "penpot-prod-bastion-ip"
  region      = var.region
  description = "Static external IP for bastion (prod)"
  lifecycle {
    prevent_destroy = true
  }
}

# Monitoring public IP (Grafana/Prometheus entry point for prod). Expose Grafana if needed.
resource "google_compute_address" "monitoring_prod" {
  name        = "penpot-prod-monitoring-ip"
  region      = var.region
  description = "Static external IP for monitoring (prod)"
  lifecycle {
    prevent_destroy = true
  }
}
