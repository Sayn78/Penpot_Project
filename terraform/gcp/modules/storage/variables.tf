variable "assets_bucket_name" {
  type        = string
  description = "Name of the GCS bucket for Penpot assets"
}

variable "project_id" {
  type        = string
  description = "GCP project ID (for service account creation)"
}

variable "assets_bucket_location" {
  type        = string
  description = "Bucket location (region or multi-region, e.g., europe-west9 or EU)"
}

variable "assets_bucket_class" {
  type        = string
  description = "Storage class (e.g., STANDARD, NEARLINE)"
  default     = "STANDARD"
}

variable "assets_bucket_versioning" {
  type        = bool
  description = "Enable object versioning"
  default     = true
}

variable "assets_bucket_labels" {
  type        = map(string)
  description = "Labels for the assets bucket"
  default     = {}
}

variable "assets_service_account_name" {
  type        = string
  description = "Service account name (account_id) dedicated to assets bucket access"
  default     = "penpot-assets-sa"
}
