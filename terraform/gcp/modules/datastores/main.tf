# Cloud SQL Postgres with private IP via PSA (IPv4 disabled).
resource "google_sql_database_instance" "postgres" {
  name             = var.cloudsql_instance_name
  database_version = var.cloudsql_database_version
  region           = var.region

  # Disabled to allow full destroy in ephemeral/test workflows; enable in production once policies/guards are set.
  deletion_protection = false

  settings {
    tier              = var.cloudsql_tier
    availability_type = var.cloudsql_availability_type
    disk_size         = var.cloudsql_disk_size_gb
    disk_autoresize   = true
    # Force SSD storage class for predictable performance
    disk_type = "PD_SSD"

    # For Cloud SQL, setting private_network + ipv4_enabled=false automatically uses the Service Networking peering (PSA).
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network_self_link
    }
  }
}

# Application DB user
resource "google_sql_user" "app" {
  name     = var.cloudsql_username
  instance = google_sql_database_instance.postgres.name
  password = var.cloudsql_password
}

# Create the Penpot database
resource "google_sql_database" "penpot" {
  name     = "penpot"
  instance = google_sql_database_instance.postgres.name
}

# Redis MemoryStore with private service access (uses PSA). connect_mode explicitly selects PSA.
resource "google_redis_instance" "redis" {
  name           = var.redis_name
  project        = var.project_id
  region         = var.region
  tier           = var.redis_tier
  memory_size_gb = var.redis_memory_size_gb

  # Attach to VPC/PSA
  authorized_network = var.network_self_link
  # Explicitly use PSA
  connect_mode = "PRIVATE_SERVICE_ACCESS"

  labels = var.redis_labels
}
