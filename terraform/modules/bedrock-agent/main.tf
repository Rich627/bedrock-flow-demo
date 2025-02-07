##############################
# Bedrock Agent Configuration
##############################

#################
# Agent Creation
# Creates Bedrock Agents with Knowledge Base integration
#################
resource "awscc_bedrock_agent" "this" {
  for_each = { for agent in var.agents : agent.name => agent }
  
  agent_name              = each.value.name
  description            = "Agent for ${each.value.department} department"
  agent_resource_role_arn = aws_iam_role.bedrock_agent[each.key].arn
  foundation_model       = data.aws_bedrock_foundation_model.agent.model_id
  instruction           = file("${path.module}/instruction.txt")
  
  knowledge_bases = [{
    description          = "${each.value.department} knowledge base"
    knowledge_base_id    = each.value.kb_id
    knowledge_base_state = "ENABLED"
  }]
  
  idle_session_ttl_in_seconds = 600
  auto_prepare               = true

  tags = {
    Department = each.value.department
  }
}

#################
# Agent IAM Role
# Creates IAM roles for Bedrock Agents
#################
resource "aws_iam_role" "bedrock_agent" {
  for_each = { for agent in var.agents : agent.name => agent }
  
  name = "BedrockAgentRole_${each.value.department}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = local.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:${local.partition}:bedrock:${local.region}:${local.account_id}:agent/*"
          }
        }
      }
    ]
  })
}

#################
# Agent Policies
# Configures permissions for Bedrock Agents
#################
resource "aws_iam_role_policy" "bedrock_agent_model" {
  for_each = aws_iam_role.bedrock_agent
  name     = "AmazonBedrockAgentBedrockFoundationModelPolicy_${each.key}"
  role     = each.value.name
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "bedrock:InvokeModel"
        Effect   = "Allow"
        Resource = data.aws_bedrock_foundation_model.agent.model_arn
      }
    ]
  })
}

resource "aws_iam_role_policy" "bedrock_agent_kb" {
  for_each = { for agent in var.agents : agent.name => agent }
  name     = "AmazonBedrockAgentBedrockKnowledgeBasePolicy_${each.key}"
  role     = aws_iam_role.bedrock_agent[each.key].name
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "bedrock:Retrieve"
        Effect   = "Allow"
        Resource = each.value.kb_arn
      }
    ]
  })
}