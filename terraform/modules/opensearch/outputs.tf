output "collection_arns" {
  description = "Map of collection names to their ARNs"
  value       = { for k, v in aws_opensearchserverless_collection.this : k => v.arn }
}

output "index_names" {
  description = "Map of collection names to their index names"
  value       = { for k, v in opensearch_index.this : k => v.name }
}

output "collection_endpoints" {
  description = "Map of collection names to their endpoints"
  value       = { for k, v in aws_opensearchserverless_collection.this : k => v.collection_endpoint }
}