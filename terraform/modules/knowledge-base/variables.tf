variable "knowledge_bases" {
  type = list(object({
    name = string
    department = string
    s3_arn = string
    opensearch_arn = string
    opensearch_index_name = string
  }))
  description = "List of knowledge bases to be created"
}

variable "bedrock_role_arn" {
  type        = string
  description = "The ARN of the Bedrock role"
}

variable "bedrock_role_name" {
  type        = string
  description = "The name of the Bedrock role"
}

variable "kb_model_arn" {
  type        = string
  description = "The ARN of the Knowledge Base model"
  default     = "arn:aws:bedrock:ap-northeast-1::foundation-model/cohere.embed-multilingual-v3.0"
}

# These variables are still needed for backward compatibility
variable "opensearch_arn" {
  type        = string
  description = "The ARN of the OpenSearch domain"
  default     = null
}

variable "opensearch_index_name" {
  type        = string
  description = "The name of the OpenSearch index"
  default     = null
}

variable "s3_arn" {
  type        = string
  description = "The ARN of the S3 bucket"
  default     = null
}

variable "index_name_prefix" {
  type        = string
  description = "The prefix for OpenSearch index names"
  default     = "pds"
}