variable "network_id" {
  type        = string
  description = "Network ID (self link/ID for firewalls)"
}

variable "network_name" {
  type        = string
  description = "Network name (used in firewall names)"
}

variable "subnet_private_cidr" {
  type        = string
  description = "Private subnet CIDR for internal rules"
}
variable "subnet_public_cidr" {
  type        = string
  description = "Public subnet CIDR for internal rules"
}
variable "ssh_allowed_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks allowed to access SSH on bastion"
}
