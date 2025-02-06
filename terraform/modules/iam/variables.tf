variable "departments" {
  type = list(object({
    name = string
    s3_arn = string
  }))
  description = "List of departments with their S3 bucket ARNs"
}

variable "bedrock_role_name" {
  type        = string
  description = "The name of the Bedrock role"
  default     = "bedrock-kb-role"
}

variable "kb_model_arn" {
  type        = string
  description = "The ARN of the Knowledge Base model"
}

# These variables are still needed for backward compatibility
variable "kb_name" {
  description = "The knowledge base name."
  type        = string
  default     = null
}

variable "agent_name" {
  description = "The agent name."
  type        = string
  default     = null
}

variable "action_group_name" {
  description = "The action group name."
  type        = string
  default     = null
}

variable "lambda_iam_policy" {
  type        = string
  description = "The ARN of the Lambda execution policy"
  default     = null
}

variable "s3_arn" {
  type        = string
  description = "The ARN of the S3 bucket"
  default     = null
}

variable "custom_model_s3_arn" {
  type        = string
  description = "The ARN of the custom model S3 bucket"
  default     = null
}