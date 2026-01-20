# Public SSH to bastion only (OS Login). No other public SSH is allowed.
resource "google_compute_firewall" "ssh_oslogin_bastion_public" {
  name    = "${var.network_name}-ssh-bastion-public"
  network = var.network_id

  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
    ports    = ["22", "4222"]
  }

  source_ranges = var.ssh_allowed_cidrs
  target_tags   = ["bastion"]

  description = "Allow SSH to bastion (OS Login) from authorized CIDR blocks"
}

# Public HTTP/HTTPS to manager (Traefik/UI entrypoint)
resource "google_compute_firewall" "http_https" {
  name    = "${var.network_name}-http-https"
  network = var.network_id

  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["manager"]

  description = "Allow HTTP/HTTPS to the Swarm manager / Traefik entrypoint"
}

# Public HTTP/HTTPS to monitoring (Grafana)
resource "google_compute_firewall" "http_https_monitoring" {
  name    = "${var.network_name}-monitoring-http-https"
  network = var.network_id

  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["monitoring"]

  description = "Allow HTTP/HTTPS to monitoring (Grafana) only"
}

# Public observability ports (Grafana 3000, Loki 3100, Prometheus 9090)
resource "google_compute_firewall" "observability_monitoring" {
  name    = "${var.network_name}-monitoring-observability"
  network = var.network_id

  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
    ports    = ["3000", "3100", "9090"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["monitoring"]

  description = "Allow Grafana (3000), Loki (3100) and Prometheus (9090)"
}

# Swarm control plane (tcp/2377) to manager
resource "google_compute_firewall" "swarm_manager" {
  name    = "${var.network_name}-swarm-manager"
  network = var.network_id

  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
    ports    = ["2377"]
  }

  source_ranges = [var.subnet_private_cidr, var.subnet_public_cidr]
  target_tags   = ["manager"]

  description = "Allow Swarm control-plane traffic (tcp/2377) to manager"
}

# Swarm data/overlay gossip between all nodes (manager + workers)
resource "google_compute_firewall" "swarm_data" {
  name    = "${var.network_name}-swarm-data"
  network = var.network_id

  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
    ports    = ["7946"]
  }

  allow {
    protocol = "udp"
    ports    = ["7946", "4789"]
  }

  source_ranges = [var.subnet_private_cidr, var.subnet_public_cidr]
  target_tags   = ["manager", "worker"]

  description = "Allow Swarm gossip/overlay traffic between manager and workers"
}

# Prometheus (monitoring) -> node_exporter (9100) on manager/worker
resource "google_compute_firewall" "monitoring_node_exporter" {
  name    = "${var.network_name}-monitoring-node-exporter"
  network = var.network_id

  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
    ports    = ["9100"]
  }

  source_tags = ["monitoring"]
  target_tags = ["manager", "worker"]

  description = "Allow Prometheus (monitoring) to scrape node_exporter (9100) on manager/worker"
}

# Prometheus (monitoring) -> Traefik metrics on manager (tcp/8082)
resource "google_compute_firewall" "monitoring_traefik_metrics" {
  name    = "${var.network_name}-monitoring-traefik-metrics"
  network = var.network_id

  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
    ports    = ["8082"]
  }

  source_tags = ["monitoring"]
  target_tags = ["manager"]

  description = "Allow Prometheus (monitoring) to scrape Traefik metrics (tcp/8082) on manager"
}

# SSH from bastion to internal hosts (OS Login)
resource "google_compute_firewall" "bastion_to_internal_ssh" {
  name    = "${var.network_name}-bastion-ssh"
  network = var.network_id

  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_tags = ["bastion"]
  target_tags = ["ssh-oslogin"]

  description = "Allow SSH from bastion to internal hosts (OS Login)"
}
