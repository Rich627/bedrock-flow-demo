resource "aws_opensearchserverless_access_policy" "this" {
  for_each = { for collection in var.collections : collection.name => collection }
  name = each.value.name
  type = "data"
  policy = jsonencode([
    {
      Rules = [
        {
          ResourceType = "collection"
          Resource = [
            "collection/${each.value.name}"
          ]
          Permission = [
            "aoss:CreateCollectionItems",
            "aoss:DeleteCollectionItems",
            "aoss:DescribeCollectionItems",
            "aoss:UpdateCollectionItems"
          ]
        },
        {
          ResourceType = "index"
          Resource = [
            "index/${each.value.name}/*"
          ]
          Permission = [
            "aoss:CreateIndex",
            "aoss:DeleteIndex",
            "aoss:DescribeIndex",
            "aoss:ReadDocument",
            "aoss:UpdateIndex",
            "aoss:WriteDocument"
          ]
        }
      ],
      Principal = [
        var.bedrock_role_arn,
        data.aws_caller_identity.this.arn,
        "arn:aws:sts::${data.aws_caller_identity.this.account_id}:assumed-role/bedrock-codepipeline-role/*"  
      ]
    }
  ])
}

resource "aws_opensearchserverless_security_policy" "encryption" {
  for_each = { for collection in var.collections : collection.name => collection }
  name = each.value.name
  type = "encryption"
  policy = jsonencode({
    Rules = [
      {
        Resource = [
          "collection/${each.value.name}"
        ]
        ResourceType = "collection"
      }
    ],
    AWSOwnedKey = true
  })
}

resource "aws_opensearchserverless_security_policy" "network" {
  for_each = { for collection in var.collections : collection.name => collection }
  name = each.value.name
  type = "network"
  policy = jsonencode([
    {
      Rules = [
        {
          ResourceType = "collection"
          Resource = [
            "collection/${each.value.name}"
          ]
        },
        {
          ResourceType = "dashboard"
          Resource = [
            "collection/${each.value.name}"
          ]
        }
      ]
      AllowFromPublic = true
    }
  ])
}

resource "aws_opensearchserverless_collection" "this" {
  for_each = { for collection in var.collections : collection.name => collection }
  name = each.value.name
  type = "VECTORSEARCH"

  tags = {
    Department = each.value.department
  }

  depends_on = [
    aws_opensearchserverless_access_policy.this,
    aws_opensearchserverless_security_policy.encryption,
    aws_opensearchserverless_security_policy.network
  ]
}

resource "time_sleep" "wait_before_index_creation" {
  depends_on      = [aws_opensearchserverless_collection.this]
  create_duration = "120s"
}

# 首先定義所有需要的 provider 配置
provider "opensearch" {
  alias       = "hr"
  url         = aws_opensearchserverless_collection.this["bedrock-flow-hr"].collection_endpoint
  healthcheck = false
}

provider "opensearch" {
  alias       = "finance"
  url         = aws_opensearchserverless_collection.this["bedrock-flow-finance"].collection_endpoint
  healthcheck = false
}

# 然後在索引資源中使用對應的 provider
resource "opensearch_index" "hr" {
  provider                      = opensearch.hr
  name                          = lower("${var.index_name_prefix}-HR")
  number_of_shards              = "2"
  number_of_replicas            = "0"
  index_knn                     = true
  index_knn_algo_param_ef_search = "512"
  mappings                      = <<-EOF
    {
      "properties": {
        "bedrock-knowledge-base-default-vector": {
          "type": "knn_vector",
          "dimension": 1024,
          "method": {
            "name": "hnsw",
            "engine": "faiss",
            "parameters": {
              "m": 16,
              "ef_construction": 512
            },
            "space_type": "l2"
          }
        },
        "AMAZON_BEDROCK_METADATA": {
          "type": "text",
          "index": "false"
        },
        "AMAZON_BEDROCK_TEXT_CHUNK": {
          "type": "text",
          "index": "true"
        }
      }
    }
  EOF
  force_destroy                 = true
  depends_on                    = [time_sleep.wait_before_index_creation]
}

resource "opensearch_index" "finance" {
  provider                      = opensearch.finance
  name                          = lower("${var.index_name_prefix}-Finance")
  number_of_shards              = "2"
  number_of_replicas            = "0"
  index_knn                     = true
  index_knn_algo_param_ef_search = "512"
  mappings                      = <<-EOF
    {
      "properties": {
        "bedrock-knowledge-base-default-vector": {
          "type": "knn_vector",
          "dimension": 1024,
          "method": {
            "name": "hnsw",
            "engine": "faiss",
            "parameters": {
              "m": 16,
              "ef_construction": 512
            },
            "space_type": "l2"
          }
        },
        "AMAZON_BEDROCK_METADATA": {
          "type": "text",
          "index": "false"
        },
        "AMAZON_BEDROCK_TEXT_CHUNK": {
          "type": "text",
          "index": "true"
        }
      }
    }
  EOF
  force_destroy                 = true
  depends_on                    = [time_sleep.wait_before_index_creation]
}

resource "time_sleep" "wait_after_index_creation" {
  depends_on      = [opensearch_index.hr, opensearch_index.finance]
  create_duration = "30s"
}