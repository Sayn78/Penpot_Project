output "cloudsql_instance_connection_name" {
  value = google_sql_database_instance.postgres.connection_name
}

output "cloudsql_private_ip" {
  value = google_sql_database_instance.postgres.private_ip_address
}

output "cloudsql_user" {
  value = google_sql_user.app.name
}

output "redis_host" {
  value = google_redis_instance.redis.host
}

output "redis_port" {
  value = google_redis_instance.redis.port
}

output "redis_name" {
  value = google_redis_instance.redis.name
}
