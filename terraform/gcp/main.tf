# VPC + subnets (public/private/db) and PSA peering (Cloud SQL/Redis)
module "network" {
  source                               = "./modules/network"
  network_name                         = var.network_name
  region                               = var.region
  subnet_private_name                  = var.subnet_private_name
  subnet_private_cidr                  = var.subnet_private_cidr
  subnet_private_private_google_access = var.subnet_private_private_google_access
  subnet_public_name                   = var.subnet_public_name
  subnet_public_cidr                   = var.subnet_public_cidr
  subnet_public_private_google_access  = var.subnet_public_private_google_access
  subnet_db_name                       = var.subnet_db_name
  subnet_db_cidr                       = var.subnet_db_cidr
}

# Public ingress (SSH bastion, HTTP/HTTPS front/monitoring) + internal front↔back
module "firewall" {
  source              = "./modules/firewall"
  network_id          = module.network.network_id
  network_name        = module.network.network_name
  subnet_private_cidr = module.network.subnet_private.ip_cidr_range
  subnet_public_cidr  = module.network.subnet_public.ip_cidr_range
  ssh_allowed_cidrs   = var.ssh_allowed_cidrs
}

# Consume static IPs (per env) from core ip state
data "terraform_remote_state" "core_ip" {
  backend = "gcs"
  config = {
    bucket = var.core_ip_bucket
    prefix = var.core_ip_prefix
  }
}

# Select prod or staging IPs based on use_staging_ips
locals {
  manager_ip_core    = var.use_staging_ips ? data.terraform_remote_state.core_ip.outputs.manager_ip_staging : data.terraform_remote_state.core_ip.outputs.manager_ip_prod
  bastion_ip_core    = var.use_staging_ips ? data.terraform_remote_state.core_ip.outputs.bastion_ip_staging : data.terraform_remote_state.core_ip.outputs.bastion_ip_prod
  monitoring_ip_core = var.use_staging_ips ? data.terraform_remote_state.core_ip.outputs.monitoring_ip_staging : data.terraform_remote_state.core_ip.outputs.monitoring_ip_prod
}

# VMs: manager/bastion/monitoring on public subnet (with static IPs), workers on private subnet (no public IP)
module "compute" {
  source                   = "./modules/compute"
  region                   = var.region
  network_name             = module.network.network_name
  public_subnet_self_link  = module.network.subnet_public.self_link
  private_subnet_self_link = module.network.subnet_private.self_link

  manager_zone                  = var.manager_zone
  manager_machine_type          = var.manager_machine_type
  manager_disk_size_gb          = var.manager_disk_size_gb
  manager_image                 = var.manager_image
  manager_service_account_email = var.manager_service_account_email

  worker_machine_type = var.worker_machine_type
  worker_disk_size_gb = var.worker_disk_size_gb
  worker_image        = var.worker_image
  workers             = var.workers

  bastion_zone                  = var.bastion_zone
  bastion_machine_type          = var.bastion_machine_type
  bastion_disk_size_gb          = var.bastion_disk_size_gb
  bastion_image                 = var.bastion_image
  bastion_service_account_email = var.bastion_service_account_email

  monitoring_zone                  = var.monitoring_zone
  monitoring_machine_type          = var.monitoring_machine_type
  monitoring_disk_size_gb          = var.monitoring_disk_size_gb
  monitoring_image                 = var.monitoring_image
  monitoring_service_account_email = var.monitoring_service_account_email

  manager_static_ip    = local.manager_ip_core
  bastion_static_ip    = local.bastion_ip_core
  monitoring_static_ip = local.monitoring_ip_core
}

# Cloud SQL (private IP via PSA) + Redis (private via PSA)
module "datastores" {
  source = "./modules/datastores"

  project_id        = var.project_id
  region            = var.region
  network_self_link = module.network.network_self_link

  cloudsql_instance_name     = var.cloudsql_instance_name
  cloudsql_database_version  = var.cloudsql_database_version
  cloudsql_tier              = var.cloudsql_tier
  cloudsql_disk_size_gb      = var.cloudsql_disk_size_gb
  cloudsql_availability_type = var.cloudsql_availability_type
  cloudsql_username          = var.cloudsql_username
  cloudsql_password          = var.cloudsql_password

  redis_name           = var.redis_name
  redis_tier           = var.redis_tier
  redis_memory_size_gb = var.redis_memory_size_gb
  redis_labels         = var.redis_labels

  depends_on = [module.network]
}

# AWS S3 bucket for Penpot assets
module "aws_assets" {
  source = "./modules/aws_storage"

  assets_bucket_name          = var.assets_bucket_name
  assets_bucket_versioning    = var.assets_bucket_versioning
  assets_bucket_force_destroy = var.assets_bucket_force_destroy
  assets_bucket_tags          = var.assets_bucket_labels
}

# Cloud NAT for private subnet egress (back) without public IP
module "nat" {
  source                   = "./modules/nat"
  region                   = var.region
  network_self_link        = module.network.network_self_link
  private_subnet_self_link = module.network.subnet_private.self_link
  router_name              = "${var.network_name}-router"
  nat_name                 = "${var.network_name}-nat"

  depends_on = [module.network]
}
