output "bucket_arns" {
  description = "Map of bucket names to their ARNs"
  value       = { for k, v in aws_s3_bucket.this : k => v.arn }
}

output "bucket_names" {
  description = "Map of bucket names to their IDs"
  value       = { for k, v in aws_s3_bucket.this : k => v.id }
}