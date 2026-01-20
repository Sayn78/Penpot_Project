variable "assets_bucket_name" {
  description = "S3 bucket name for Penpot assets"
  type        = string
}

variable "assets_bucket_versioning" {
  description = "Enable versioning"
  type        = bool
  default     = true
}

variable "assets_bucket_force_destroy" {
  description = "Force destroy bucket (delete objects)"
  type        = bool
  default     = true
}

variable "assets_bucket_tags" {
  description = "Tags to apply to the bucket"
  type        = map(string)
  default     = {}
}
