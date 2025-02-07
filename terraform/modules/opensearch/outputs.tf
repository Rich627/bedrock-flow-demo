output "collection_arns" {
  description = "ARNs of the OpenSearch collections"
  value       = { for k, v in aws_opensearchserverless_collection.this : k => v.arn }
}

output "index_names" {
  description = "Names of the OpenSearch indices"
  value = {
    "bedrock-flow-hr" = opensearch_index.hr.name
    "bedrock-flow-finance" = opensearch_index.finance.name
  }
}

output "collection_endpoints" {
  description = "Endpoints of the OpenSearch collections"
  value       = { for k, v in aws_opensearchserverless_collection.this : k => v.collection_endpoint }
}