# GCS bucket for Penpot assets (S3-compatible). force_destroy=true for easy teardown in tests.
resource "google_storage_bucket" "assets" {
  name     = var.assets_bucket_name
  location = var.assets_bucket_location
  # Temporary: allow destroy to purge contents for easier teardown (avoid stuck destroys in tests)
  force_destroy = true
  # Enforce access control via IAM at bucket level (disable per-object ACL); recommended by GCP
  uniform_bucket_level_access = true
  storage_class               = var.assets_bucket_class

  versioning {
    enabled = var.assets_bucket_versioning
  }

  # Optional bucket labels (env, owner, cost center, etc.)
  labels = var.assets_bucket_labels
}

# Dedicated service account to access the assets bucket (used for HMAC keys in S3 mode)
resource "google_service_account" "assets" {
  account_id   = var.assets_service_account_name
  display_name = "Penpot assets service account"
  project      = var.project_id
}

# Grant bucket-level object admin to the assets service account (minimal scope on this bucket only)
resource "google_storage_bucket_iam_member" "assets_rw" {
  bucket = google_storage_bucket.assets.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.assets.email}"
}
