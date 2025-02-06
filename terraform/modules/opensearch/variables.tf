variable "collections" {
  type = list(object({
    name = string
    department = string
  }))
  description = "List of OpenSearch collections to be created with their department names"
}

variable "bedrock_role_arn" {
  type        = string
  description = "The Amazon Resource Name (ARN) of the IAM role that grants permissions to the Bedrock resources."
}

variable "index_name_prefix" {
  type        = string
  description = "The prefix for OpenSearch index names"
  default     = "pds"
}