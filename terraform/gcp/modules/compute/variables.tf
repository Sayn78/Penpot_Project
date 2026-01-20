variable "region" {
  type        = string
  description = "Region"
}

variable "network_name" {
  type        = string
  description = "Network name for resource naming"
}

variable "public_subnet_self_link" {
  type        = string
  description = "Self link of the public subnet"
}

variable "private_subnet_self_link" {
  type        = string
  description = "Self link of the private subnet"
}

variable "manager_static_ip" {
  type        = string
  description = "Static IP for the manager node (from core stack)"
}

variable "manager_zone" {
  type        = string
  description = "Zone for manager node"
}

variable "manager_machine_type" {
  type        = string
  description = "Machine type for manager node"
}

variable "manager_disk_size_gb" {
  type        = number
  description = "Disk size for manager boot disk"
}

variable "manager_image" {
  type        = string
  description = "Boot image for manager node"
  default     = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2404-lts-amd64"
}

variable "manager_service_account_email" {
  type        = string
  description = "Service account email for manager (optional)"
  default     = ""
}

variable "worker_machine_type" {
  type        = string
  description = "Machine type for Penpot workers"
}

variable "worker_disk_size_gb" {
  type        = number
  description = "Disk size for Penpot worker boot disk"
}

variable "worker_image" {
  type        = string
  description = "Boot image for workers"
  default     = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2404-lts-amd64"
}

variable "workers" {
  type = list(object({
    name                  = string
    zone                  = string
    service_account_email = optional(string, "")
  }))
  description = "List of worker nodes (private). Each entry defines name/zone and optional service account email."
}

variable "bastion_static_ip" {
  type        = string
  description = "Static IP for bastion (from core stack)"
}

variable "bastion_zone" {
  type        = string
  description = "Zone for bastion"
}

variable "bastion_machine_type" {
  type        = string
  description = "Machine type for bastion"
}

variable "bastion_disk_size_gb" {
  type        = number
  description = "Disk size for bastion boot disk"
}

variable "bastion_image" {
  type        = string
  description = "Boot image for bastion"
  default     = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2404-lts-amd64"
}

variable "bastion_service_account_email" {
  type        = string
  description = "Service account email for bastion (optional)"
  default     = ""
}

variable "monitoring_static_ip" {
  type        = string
  description = "Static IP for monitoring (from core stack)"
}

variable "monitoring_zone" {
  type        = string
  description = "Zone for monitoring VM"
}

variable "monitoring_machine_type" {
  type        = string
  description = "Machine type for monitoring VM"
}

variable "monitoring_disk_size_gb" {
  type        = number
  description = "Disk size for monitoring boot disk"
}

variable "monitoring_image" {
  type        = string
  description = "Boot image for monitoring VM"
  default     = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2404-lts-amd64"
}

variable "monitoring_service_account_email" {
  type        = string
  description = "Service account email for monitoring (optional)"
  default     = ""
}

variable "auto_start_cron" {
  type        = string
  description = "Cron expression for auto-start (uses time_zone)"
  default     = "0 7 * * 1-5" # 07:00, Monday-Friday
}

variable "auto_stop_cron" {
  type        = string
  description = "Cron expression for auto-stop (uses time_zone)"
  # Stop every day at 19:00 to ensure weekend shutdown (starts only Mon-Fri)
  default = "0 19 * * *"
}

variable "auto_schedule_timezone" {
  type        = string
  description = "Timezone for the auto start/stop schedule"
  default     = "Europe/Paris"
}

variable "extra_resource_policies" {
  type        = list(string)
  description = "Additional resource policies to attach to all instances (self_links)"
  default     = []
}
