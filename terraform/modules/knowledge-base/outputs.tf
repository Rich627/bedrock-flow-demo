output "kb_ids" {
  description = "Map of knowledge base names to their IDs"
  value       = { for k, v in aws_bedrockagent_knowledge_base.this : k => v.id }
}

output "kb_arns" {
  description = "Map of knowledge base names to their ARNs"
  value       = { for k, v in aws_bedrockagent_knowledge_base.this : k => v.arn }
}