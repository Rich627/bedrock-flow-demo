variable "kb_s3_bucket_name_prefix" {
  description = "The name prefix of the S3 bucket for the data source of the knowledge base."
  type        = string
  default     = "bedrock-flow-test"
}

variable "kb_oss_collection_name_hr" {
  description = "The name of the OpenSearch Service (OSS) collection for the HR knowledge base."
  type        = string
  default     = "bedrock-kb-hr"
}

variable "kb_oss_collection_name_finance" {
  description = "The name of the OpenSearch Service (OSS) collection for the Finance knowledge base."
  type        = string
  default     = "bedrock-kb-finance"
}

variable "kb_model_id" {
  description = "The ID of the foundational model used by the knowledge base."
  type        = string
  default     = "cohere.embed-multilingual-v3"
}

variable "kb_name_hr" {
  description = "The name of the HR knowledge base."
  type        = string
  default     = "bedrock-flow-test-hr"
}

variable "kb_name_finance" {
  description = "The name of the Finance knowledge base."
  type        = string
  default     = "bedrock-flow-test-finance"
}

variable "agent_model_id" {
  description = "The ID of the foundational model used by the agent."
  type        = string
  default     = "anthropic.claude-3-haiku-20240307-v1:0"
}

variable "agent_name_hr" {
  description = "The name of the HR agent."
  type        = string
  default     = "bedrock-flow-test-agent-hr"
}

variable "agent_name_finance" {
  description = "The name of the Finance agent."
  type        = string
  default     = "bedrock-flow-test-agent-finance"
}

variable "agent_desc" {
  description = "The description of the agent."
  type        = string
  default     = "An assistant that provides sample information."
}

variable "action_group_name" {
  description = "The name of the action group."
  type        = string
  default     = "sampleAPI"
}

variable "action_group_desc" {
  description = "The description of the action group."
  type        = string
  default     = "An action group that provides sample information."
}

variable "subnet_ids" {
  type        = list(string)
  description = "The list of subnet IDs where the Lambda function will be deployed."
  default     = ["subnet-123"]
}

variable "security_group_ids" {
  type        = list(string)
  description = "The list of security group IDs to be associated with the Lambda function."
  default     = ["sg-123"]
}