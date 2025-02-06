output "agent_ids" {
  description = "Map of agent names to their IDs"
  value       = { for k, v in awscc_bedrock_agent.this : k => v.agent_id }
}

output "agent_arns" {
  description = "Map of agent names to their ARNs"
  value       = { for k, v in awscc_bedrock_agent.this : k => v.agent_arn }
}