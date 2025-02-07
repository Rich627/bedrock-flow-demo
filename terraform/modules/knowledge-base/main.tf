##############################
# Knowledge Base Configuration
##############################

#################
# IAM Policy
# Configures OpenSearch access for Knowledge Base
#################
resource "aws_iam_role_policy" "bedrock_kb_policy" {
  for_each = { for kb in var.knowledge_bases : kb.name => kb }
  name     = "AmazonBedrockOSSPolicyForKnowledgeBase_${each.value.name}"
  role     = var.bedrock_role_name
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["aoss:*"]
        Effect   = "Allow"
        Resource = [each.value.opensearch_arn]
      }
    ]
  })
}

resource "time_sleep" "iam_consistency_delay" {
  create_duration = "120s"
  depends_on      = [aws_iam_role_policy.bedrock_kb_policy]
}

resource "aws_bedrockagent_knowledge_base" "this" {
  for_each = { for kb in var.knowledge_bases : kb.name => kb }
  name     = each.value.name
  role_arn = var.bedrock_role_arn

  knowledge_base_configuration {
    type = "VECTOR"
    vector_knowledge_base_configuration {
      embedding_model_arn = var.kb_model_arn
    }
  }

  storage_configuration {
    type = "OPENSEARCH_SERVERLESS"
    opensearch_serverless_configuration {
      collection_arn    = each.value.opensearch_arn
      vector_index_name = lower("${var.index_name_prefix}-${each.value.department}")
      field_mapping {
        vector_field   = "bedrock-knowledge-base-default-vector"
        text_field     = "AMAZON_BEDROCK_TEXT_CHUNK"
        metadata_field = "AMAZON_BEDROCK_METADATA"
      }
    }
  }

  tags = {
    Department = each.value.department
  }

  depends_on = [time_sleep.iam_consistency_delay]
}

#################
# Data Source Configuration
# Sets up S3 data sources for Knowledge Bases
#################
resource "aws_bedrockagent_data_source" "this" {
  for_each         = { for kb in var.knowledge_bases : kb.name => kb }
  knowledge_base_id = aws_bedrockagent_knowledge_base.this[each.key].id
  name             = "${each.value.name}DataSource"
  
  data_source_configuration {
    type = "S3"
    s3_configuration {
      bucket_arn = each.value.s3_arn
    }
  }
}