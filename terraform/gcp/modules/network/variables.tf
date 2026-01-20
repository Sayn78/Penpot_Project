variable "network_name" {
  type        = string
  description = "VPC network name"
}

variable "region" {
  type        = string
  description = "Region"
}

variable "subnet_private_name" {
  type        = string
  description = "Private subnet name (back/PSA)"
}

variable "subnet_private_cidr" {
  type        = string
  description = "Private subnet CIDR"
}

variable "subnet_private_private_google_access" {
  type        = bool
  description = "Enable Private Google Access on private subnet"
  default     = true
}

variable "subnet_public_name" {
  type        = string
  description = "Public subnet name (front/bastion/monitoring)"
}

variable "subnet_public_cidr" {
  type        = string
  description = "Public subnet CIDR"
}

variable "subnet_public_private_google_access" {
  type        = bool
  description = "Enable Private Google Access on public subnet"
  default     = false
}

variable "subnet_db_name" {
  type        = string
  description = "Database subnet name"
}

variable "subnet_db_cidr" {
  type        = string
  description = "Database subnet CIDR"
}
