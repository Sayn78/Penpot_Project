# AWS S3 bucket for Penpot assets (no bucket policy; access via IAM user/role policy, e.g., penpot-storage)
resource "aws_s3_bucket" "assets" {
  bucket = var.assets_bucket_name
  # allow teardown to delete objects in non-prod
  force_destroy = var.assets_bucket_force_destroy

  tags = merge({
    Name = var.assets_bucket_name
  }, var.assets_bucket_tags)
}

# Enable or suspend versioning on the assets bucket
resource "aws_s3_bucket_versioning" "assets" {
  bucket = aws_s3_bucket.assets.id
  versioning_configuration {
    status = var.assets_bucket_versioning ? "Enabled" : "Suspended"
  }
}

# Keep bucket owner preferred for object ownership
resource "aws_s3_bucket_ownership_controls" "assets" {
  bucket = aws_s3_bucket.assets.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Block all public ACLs/policies (bucket remains private; access via IAM)
resource "aws_s3_bucket_public_access_block" "assets" {
  bucket                  = aws_s3_bucket.assets.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Region info for outputs
data "aws_region" "current" {}
