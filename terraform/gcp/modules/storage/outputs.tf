output "assets_bucket_name" {
  value = google_storage_bucket.assets.name
}

output "assets_bucket_url" {
  value = "gs://${google_storage_bucket.assets.name}"
}

output "assets_service_account_email" {
  value = google_service_account.assets.email
}
