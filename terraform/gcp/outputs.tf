output "network_name" {
  description = "VPC network name"
  value       = module.network.network_name
}

output "network_self_link" {
  description = "Self link of the primary VPC network"
  value       = module.network.network_self_link
}

output "subnet_private_name" {
  description = "Private subnet name"
  value       = module.network.subnet_private.name
}

output "subnet_private_cidr" {
  description = "Private subnet CIDR"
  value       = module.network.subnet_private.ip_cidr_range
}

output "subnet_private_self_link" {
  description = "Private subnet self link"
  value       = module.network.subnet_private.self_link
}

output "subnet_public_name" {
  description = "Public subnet name"
  value       = module.network.subnet_public.name
}

output "subnet_public_cidr" {
  description = "Public subnet CIDR"
  value       = module.network.subnet_public.ip_cidr_range
}

output "subnet_public_self_link" {
  description = "Public subnet self link"
  value       = module.network.subnet_public.self_link
}

output "subnet_db_name" {
  description = "Database subnet name"
  value       = module.network.subnet_db.name
}

output "subnet_db_cidr" {
  description = "Database subnet CIDR"
  value       = module.network.subnet_db.ip_cidr_range
}

output "subnet_db_self_link" {
  description = "Database subnet self link"
  value       = module.network.subnet_db.self_link
}

output "manager_instance_name" {
  description = "Manager instance name (Swarm/public entrypoint)"
  value       = module.compute.manager_instance_name
}

output "manager_instance_ip" {
  description = "Manager external IP"
  value       = module.compute.manager_instance_ip
}

output "worker_instance_names" {
  description = "Worker instance names"
  value       = module.compute.worker_instance_names
}

output "worker_instance_ips" {
  description = "Worker private IPs (map name -> IP)"
  value       = module.compute.worker_instance_ips
}

output "bastion_instance_name" {
  description = "Bastion instance name"
  value       = module.compute.bastion_instance_name
}

output "bastion_instance_ip" {
  description = "Bastion external IP"
  value       = module.compute.bastion_instance_ip
}

output "monitoring_instance_name" {
  description = "Monitoring instance name"
  value       = module.compute.monitoring_instance_name
}

output "monitoring_instance_ip" {
  description = "Monitoring external IP"
  value       = module.compute.monitoring_instance_ip
}

output "cloudsql_instance_connection_name" {
  description = "Cloud SQL instance connection name"
  value       = module.datastores.cloudsql_instance_connection_name
}

output "cloudsql_private_ip" {
  description = "Cloud SQL private IP address"
  value       = module.datastores.cloudsql_private_ip
}

output "cloudsql_user" {
  description = "Cloud SQL application user"
  value       = module.datastores.cloudsql_user
}

output "redis_host" {
  description = "Redis host (MemoryStore private endpoint)"
  value       = module.datastores.redis_host
}

output "redis_port" {
  description = "Redis port"
  value       = module.datastores.redis_port
}

output "redis_name" {
  description = "Redis instance name"
  value       = module.datastores.redis_name
}

output "assets_bucket_name" {
  description = "S3 bucket for Penpot assets"
  value       = module.aws_assets.assets_bucket_name
}

output "assets_bucket_arn" {
  description = "S3 bucket ARN for Penpot assets"
  value       = module.aws_assets.assets_bucket_arn
}

output "assets_bucket_region" {
  description = "AWS region of the assets bucket"
  value       = module.aws_assets.assets_bucket_region
}
