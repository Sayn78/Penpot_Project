variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "core_ip_bucket" {
  description = "GCS bucket for core IP remote state"
  type        = string
}

variable "core_ip_prefix" {
  description = "GCS prefix for core IP remote state (prod/staging share the same state if desired)"
  type        = string
}

variable "use_staging_ips" {
  description = "If true, use staging IPs from core; otherwise use prod IPs"
  type        = bool
  default     = false
}

variable "region" {
  description = "GCP region for resources"
  type        = string
}

variable "network_name" {
  description = "VPC network name"
  type        = string
}

variable "subnet_private_name" {
  description = "Subnet name for private resources (workers/PSA services)"
  type        = string
}

variable "subnet_private_cidr" {
  description = "CIDR range for the private subnet"
  type        = string
}

variable "subnet_private_private_google_access" {
  description = "Enable Private Google Access on the private subnet"
  type        = bool
  default     = true
}

variable "subnet_public_name" {
  description = "Subnet name for public resources (manager/bastion/monitoring)"
  type        = string
}

variable "subnet_public_cidr" {
  description = "CIDR range for the public subnet"
  type        = string
}

variable "subnet_public_private_google_access" {
  description = "Enable Private Google Access on the public subnet"
  type        = bool
  default     = false
}

variable "subnet_db_name" {
  description = "Subnet name for database (Cloud SQL private)"
  type        = string
}

variable "subnet_db_cidr" {
  description = "CIDR range for the database subnet"
  type        = string
}

variable "ssh_allowed_cidrs" {
  description = "CIDR blocks allowed to SSH (OS Login) into instances"
  type        = list(string)
}

variable "manager_zone" {
  description = "Zone for the Swarm manager (public entrypoint)"
  type        = string
}

variable "manager_machine_type" {
  description = "Machine type for the manager node"
  type        = string
}

variable "manager_disk_size_gb" {
  description = "Boot disk size (GB) for the manager node"
  type        = number
}

variable "manager_image" {
  description = "Boot image for the manager node"
  type        = string
  default     = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2404-lts-amd64"
}

variable "manager_service_account_email" {
  description = "Service account email to attach to the manager node (optional)"
  type        = string
  default     = ""
}

variable "worker_machine_type" {
  description = "Machine type for Penpot workers"
  type        = string
}

variable "worker_disk_size_gb" {
  description = "Boot disk size (GB) for Penpot workers"
  type        = number
}

variable "worker_image" {
  description = "Boot image for Penpot workers"
  type        = string
  default     = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"
}

variable "workers" {
  description = "List of worker nodes (private). Each entry defines name/zone and optional service account email."
  type = list(object({
    name                  = string
    zone                  = string
    service_account_email = optional(string, "")
  }))
}

variable "redis_name" {
  description = "Redis MemoryStore instance name"
  type        = string
}

variable "redis_tier" {
  description = "Redis tier (BASIC or STANDARD_HA)"
  type        = string
  default     = "BASIC"
}

variable "redis_memory_size_gb" {
  description = "Redis memory size in GB"
  type        = number
  default     = 1
}

variable "redis_labels" {
  description = "Labels for Redis"
  type        = map(string)
  default     = {}
}

variable "cloudsql_instance_name" {
  description = "Cloud SQL instance name"
  type        = string
}

variable "cloudsql_database_version" {
  description = "Cloud SQL PostgreSQL version (e.g., POSTGRES_15)"
  type        = string
}

variable "cloudsql_tier" {
  description = "Cloud SQL tier (e.g., db-custom-2-8192)"
  type        = string
}

variable "cloudsql_disk_size_gb" {
  description = "Cloud SQL disk size in GB"
  type        = number
}

variable "cloudsql_availability_type" {
  description = "Cloud SQL availability type (ZONAL or REGIONAL)"
  type        = string
}

variable "cloudsql_username" {
  description = "Cloud SQL database user (do not commit secrets)"
  type        = string
}

variable "cloudsql_password" {
  description = "Cloud SQL database user password (set via tfvars/CI, do not commit)"
  type        = string
  sensitive   = true
}

variable "bastion_zone" {
  description = "Zone for the bastion instance"
  type        = string
}

variable "bastion_machine_type" {
  description = "Machine type for bastion"
  type        = string
}

variable "bastion_disk_size_gb" {
  description = "Boot disk size (GB) for bastion"
  type        = number
}

variable "bastion_image" {
  description = "Boot image for bastion instance"
  type        = string
  default     = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"
}

variable "bastion_service_account_email" {
  description = "Service account email to attach to bastion instance (optional)"
  type        = string
  default     = ""
}

variable "monitoring_zone" {
  description = "Zone for the monitoring instance"
  type        = string
}

variable "monitoring_machine_type" {
  description = "Machine type for monitoring"
  type        = string
}

variable "monitoring_disk_size_gb" {
  description = "Boot disk size (GB) for monitoring"
  type        = number
}

variable "monitoring_image" {
  description = "Boot image for monitoring instance"
  type        = string
  default     = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"
}

variable "monitoring_service_account_email" {
  description = "Service account email to attach to monitoring instance (optional)"
  type        = string
  default     = ""
}

variable "assets_bucket_name" {
  description = "S3 bucket name for Penpot assets (AWS)"
  type        = string
}

variable "assets_bucket_versioning" {
  description = "Enable versioning on the assets bucket"
  type        = bool
  default     = true
}

variable "assets_bucket_labels" {
  description = "Tags/labels for the assets bucket"
  type        = map(string)
  default     = {}
}

variable "assets_bucket_force_destroy" {
  description = "Allow force destroy (delete objects with bucket) - useful for test/teardown"
  type        = bool
  default     = true
}

variable "aws_region" {
  description = "AWS region for the assets S3 bucket"
  type        = string
}

variable "nat_router_name" {
  description = "Cloud Router name for NAT"
  type        = string
}

variable "nat_name" {
  description = "Cloud NAT name"
  type        = string
}
