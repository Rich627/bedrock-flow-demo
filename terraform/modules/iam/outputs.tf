output "bedrock_role_arns" {
  description = "Map of department names to their Bedrock IAM role ARNs"
  value       = { for k, v in aws_iam_role.bedrock_kb : k => v.arn }
}

output "bedrock_role_names" {
  description = "Map of department names to their Bedrock IAM role names"
  value       = { for k, v in aws_iam_role.bedrock_kb : k => v.name }
}