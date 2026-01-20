# Bastion: only public SSH entrypoint (OS Login). Lives on public subnet with static IP. No other VM exposes SSH publicly.
resource "google_compute_instance" "bastion" {
  name         = "${var.network_name}-bastion"
  description  = "Bastion host for SSH access"
  machine_type = var.bastion_machine_type
  zone         = var.bastion_zone

  tags = [
    "ssh-oslogin",
    "bastion",
  ]

  boot_disk {
    initialize_params {
      image = var.bastion_image
      size  = var.bastion_disk_size_gb
      # Selects the balanced persistent disk type for better price/performance.
      type = "pd-balanced"
    }
  }

  network_interface {
    # Attach this interface to the shared public subnet.
    subnetwork = var.public_subnet_self_link

    access_config {
      # Enable an external access config so the bastion receives a public IP.
      nat_ip = var.bastion_static_ip
    }
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  dynamic "service_account" {
    for_each = var.bastion_service_account_email != "" ? [var.bastion_service_account_email] : []
    content {
      email = service_account.value
      scopes = [
        "https://www.googleapis.com/auth/logging.write",
        "https://www.googleapis.com/auth/monitoring.write",
      ]
    }
  }

  resource_policies = local.resource_policies
}

# Manager: public-facing entrypoint (Traefik + UI). Public subnet + static IP for DNS. Exposed on HTTP/HTTPS.
resource "google_compute_instance" "manager" {
  name         = "${var.network_name}-manager"
  description  = "Manager node (Traefik + UI entrypoint)"
  machine_type = var.manager_machine_type
  zone         = var.manager_zone

  tags = [
    "ssh-oslogin",
    "manager",
  ]

  boot_disk {
    initialize_params {
      image = var.manager_image
      size  = var.manager_disk_size_gb
      # Selects the balanced persistent disk type for better price/performance.
      type = "pd-balanced"
    }
  }

  network_interface {
    # Attach this interface to the shared public subnet.
    subnetwork = var.public_subnet_self_link

    access_config {
      # Enable an external access config so the front receives a public IP.
      nat_ip = var.manager_static_ip
    }
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  dynamic "service_account" {
    for_each = var.manager_service_account_email != "" ? [var.manager_service_account_email] : []
    content {
      email = service_account.value
      scopes = [
        "https://www.googleapis.com/auth/logging.write",
        "https://www.googleapis.com/auth/monitoring.write",
      ]
    }
  }

  resource_policies = local.resource_policies
}

# Worker: Penpot application server (Swarm node). Private subnet only, no public IP.
resource "google_compute_instance" "worker" {
  for_each     = { for w in var.workers : w.name => w }
  name         = "${var.network_name}-${each.value.name}"
  description  = "Penpot worker (Swarm node, private)"
  machine_type = var.worker_machine_type
  zone         = each.value.zone

  tags = [
    "ssh-oslogin",
    "worker",
  ]

  boot_disk {
    initialize_params {
      image = var.worker_image
      size  = var.worker_disk_size_gb
      # Selects the balanced persistent disk type for better price/performance.
      type = "pd-balanced"
    }
  }

  network_interface {
    # Attach this interface to the shared private subnet.
    subnetwork = var.private_subnet_self_link
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  dynamic "service_account" {
    for_each = lookup(each.value, "service_account_email", "") != "" ? [each.value.service_account_email] : []
    content {
      email = service_account.value
      scopes = [
        "https://www.googleapis.com/auth/logging.write",
        "https://www.googleapis.com/auth/monitoring.write",
      ]
    }
  }

  resource_policies = local.resource_policies
}

# Monitoring: Grafana/Prometheus endpoint. Public subnet + static IP for external access if desired.
resource "google_compute_instance" "monitoring" {
  name         = "${var.network_name}-monitoring"
  description  = "Monitoring (Prometheus + Grafana)"
  machine_type = var.monitoring_machine_type
  zone         = var.monitoring_zone

  tags = [
    "ssh-oslogin",
    "monitoring",
  ]

  boot_disk {
    initialize_params {
      image = var.monitoring_image
      size  = var.monitoring_disk_size_gb
      # Selects the balanced persistent disk type for better price/performance.
      type = "pd-balanced"
    }
  }

  network_interface {
    # Attach this interface to the shared public subnet.
    subnetwork = var.public_subnet_self_link

    access_config {
      # Enable an external access config so monitoring receives a public IP.
      nat_ip = var.monitoring_static_ip
    }
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  dynamic "service_account" {
    for_each = var.monitoring_service_account_email != "" ? [var.monitoring_service_account_email] : []
    content {
      email = service_account.value
      scopes = [
        "https://www.googleapis.com/auth/logging.write",
        "https://www.googleapis.com/auth/monitoring.write",
      ]
    }
  }

  resource_policies = local.resource_policies
}

# Instance schedule policy: auto start/stop (07:00 Mon-Fri start, 19:00 daily stop)
resource "google_compute_resource_policy" "auto_start_stop" {
  count       = 1
  name        = "${var.network_name}-auto-start-stop-weekdays-7-19"
  region      = var.region
  description = "Auto start 07:00 Mon-Fri, stop 19:00 daily for ${var.network_name} instances"

  instance_schedule_policy {
    vm_start_schedule {
      schedule = var.auto_start_cron
    }
    vm_stop_schedule {
      schedule = var.auto_stop_cron
    }
    time_zone       = var.auto_schedule_timezone
    expiration_time = null
  }
}

# Collect all resource policies to attach to instances (auto schedule + any extra)
locals {
  resource_policies = concat(
    var.extra_resource_policies,
    google_compute_resource_policy.auto_start_stop[*].self_link
  )
}
