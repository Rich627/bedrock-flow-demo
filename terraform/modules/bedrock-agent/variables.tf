variable "agents" {
  type = list(object({
    name = string
    department = string
    kb_id = string
    kb_arn = string
  }))
  description = "List of Bedrock agents to be created"
}

variable "agent_model_id" {
  description = "The ID of the foundational model used by the agent."
  type        = string
  default     = "anthropic.claude-3.5-sonnet-20240620-v1:0"
}

# These variables are still needed for backward compatibility
variable "agent_name" {
  description = "The name of the agent."
  type        = string
  default     = null
}

variable "kb_id" {
  description = "The ID of the knowledge base associated with the agent."
  type        = string
  default     = null
}

variable "kb_arn" {
  description = "The Amazon Resource Name (ARN) of the knowledge base associated with the agent."
  type        = string
  default     = null
}