variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "region" {
  type        = string
  description = "Region"
}

variable "network_self_link" {
  type        = string
  description = "VPC self link for private services (Cloud SQL, Redis)"
}

variable "cloudsql_instance_name" {
  type        = string
  description = "Cloud SQL instance name"
}

variable "cloudsql_database_version" {
  type        = string
  description = "Cloud SQL database version (e.g., POSTGRES_15)"
}

variable "cloudsql_tier" {
  type        = string
  description = "Cloud SQL tier (e.g., db-custom-2-8192)"
}

variable "cloudsql_disk_size_gb" {
  type        = number
  description = "Disk size (GB) for Cloud SQL"
}

variable "cloudsql_availability_type" {
  type        = string
  description = "Availability type (ZONAL or REGIONAL)"
}

variable "cloudsql_username" {
  type        = string
  description = "DB username"
}

variable "cloudsql_password" {
  type        = string
  description = "DB password (sensitive)"
  sensitive   = true
}

variable "redis_name" {
  type        = string
  description = "Name of the Redis instance"
}

variable "redis_tier" {
  type        = string
  description = "Redis tier (BASIC or STANDARD_HA)"
  default     = "BASIC"
}

variable "redis_memory_size_gb" {
  type        = number
  description = "Redis memory size in GB"
  default     = 1
}

variable "redis_labels" {
  type        = map(string)
  description = "Optional labels for Redis"
  default     = {}
}
