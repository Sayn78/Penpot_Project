variable "region" {
  type        = string
  description = "Region for the router/NAT"
}

variable "network_self_link" {
  type        = string
  description = "Self link of the VPC network"
}

variable "private_subnet_self_link" {
  type        = string
  description = "Self link of the private subnet to NAT"
}

variable "router_name" {
  type        = string
  description = "Name of the Cloud Router"
}

variable "nat_name" {
  type        = string
  description = "Name of the Cloud NAT"
}
