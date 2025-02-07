# S3 buckets for HR and Finance departments
module "pds_buckets" {
  source = "./modules/s3"
  buckets = [
    {
      name = "bedrock-flow-demo-knowledge-base-hr"
      department = "HR"
    },
    {
      name = "bedrock-flow-demo-knowledge-base-finance"
      department = "Finance"
    }
  ]
}

# Knowledge base resource role
module "sample_iam" {
  source = "./modules/iam"
  departments = [
    {
      name = "HR"
      s3_arn = module.pds_buckets.bucket_arns["bedrock-flow-demo-knowledge-base-hr"]
    },
    {
      name = "Finance"
      s3_arn = module.pds_buckets.bucket_arns["bedrock-flow-demo-knowledge-base-finance"]
    }
  ]
  kb_model_arn = data.aws_bedrock_foundation_model.kb.model_arn
}

module "opensearch" {
  source = "./modules/opensearch"
  collections = [
    {
      name = "bedrock-flow-hr"
      department = "HR"
    },
    {
      name = "bedrock-flow-finance"
      department = "Finance"
    }
  ]
  bedrock_role_arn = module.sample_iam.bedrock_role_arns["HR"]
}

module "knowledge-base" {
  source = "./modules/knowledge-base"
  knowledge_bases = [
    {
      name = "bedrock-flow-demo-kb-hr"
      department = "HR"
      s3_arn = module.pds_buckets.bucket_arns["bedrock-flow-demo-knowledge-base-hr"]
      opensearch_arn = module.opensearch.collection_arns["bedrock-flow-hr"]
      opensearch_index_name = module.opensearch.index_names["bedrock-flow-hr"]
    },
    {
      name = "bedrock-flow-demo-kb-finance"
      department = "Finance"
      s3_arn = module.pds_buckets.bucket_arns["bedrock-flow-demo-knowledge-base-finance"]
      opensearch_arn = module.opensearch.collection_arns["bedrock-flow-finance"]
      opensearch_index_name = module.opensearch.index_names["bedrock-flow-finance"]
    }
  ]
  bedrock_role_arn  = module.sample_iam.bedrock_role_arns["HR"]
  bedrock_role_name = module.sample_iam.bedrock_role_names["HR"]
  kb_model_arn      = data.aws_bedrock_foundation_model.kb.model_arn
  depends_on        = [module.opensearch]
}

module "bedrock-agent" {
  source = "./modules/bedrock-agent"
  agents = [
    {
      name = "bedrock-flow-demo-agent-hr"
      department = "HR"
      kb_id = module.knowledge-base.kb_ids["bedrock-flow-demo-kb-hr"]
      kb_arn = module.knowledge-base.kb_arns["bedrock-flow-demo-kb-hr"]
    },
    {
      name = "bedrock-flow-demo-agent-finance"
      department = "Finance"
      kb_id = module.knowledge-base.kb_ids["bedrock-flow-demo-kb-finance"]
      kb_arn = module.knowledge-base.kb_arns["bedrock-flow-demo-kb-finance"]
    }
  ]
  agent_model_id = var.agent_model_id
}

resource "terraform_data" "sample_asst_prepare" {
  triggers_replace = {
    sample_kb_state = sha256(jsonencode(module.knowledge-base))
  }
  
  provisioner "local-exec" {
    command = join(" && ", [
      for agent_id in values(module.bedrock-agent.agent_ids) : 
      "aws bedrock-agent prepare-agent --agent-id ${agent_id}"
    ])
  }
}