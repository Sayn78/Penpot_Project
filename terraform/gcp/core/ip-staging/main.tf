# Reserve stable external IPs for STAGING (manager, bastion, monitoring).
# Separate state/bucket to allow destroying/recreating staging without touching prod/DNS.
resource "google_compute_address" "manager_staging" {
  name        = "penpot-staging-manager-ip"
  region      = var.region
  description = "Static external IP for manager (staging)"
  lifecycle {
    prevent_destroy = true
  }
}

# Bastion public IP (SSH entry point for staging, OS Login only). No other public SSH in staging.
resource "google_compute_address" "bastion_staging" {
  name        = "penpot-staging-bastion-ip"
  region      = var.region
  description = "Static external IP for bastion (staging)"
  lifecycle {
    prevent_destroy = true
  }
}

# Monitoring public IP (Grafana/Prometheus entry point for staging). For observing tests/metrics.
resource "google_compute_address" "monitoring_staging" {
  name        = "penpot-staging-monitoring-ip"
  region      = var.region
  description = "Static external IP for monitoring (staging)"
  lifecycle {
    prevent_destroy = true
  }
}
