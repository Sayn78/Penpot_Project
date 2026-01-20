output "assets_bucket_name" {
  description = "S3 bucket name for Penpot assets"
  value       = aws_s3_bucket.assets.bucket
}

output "assets_bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.assets.arn
}

output "assets_bucket_region" {
  description = "AWS region for the assets bucket"
  value       = data.aws_region.current.name
}
