resource "aws_opensearchserverless_access_policy" "this" {
  for_each = { for collection in var.collections : collection.name => collection }
  name = each.value.name
  type = "data"
  policy = jsonencode([
    {
      Rules = [
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
        },
        {
          ResourceType = "collection"
          Resource = [
            "collection/${each.value.name}"
          ]
          Permission = [
            "aoss:CreateCollectionItems",
            "aoss:DescribeCollectionItems",
            "aoss:UpdateCollectionItems"
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

provider "opensearch" {
  url         = values(aws_opensearchserverless_collection.this)[0].collection_endpoint
  healthcheck = false
}

resource "time_sleep" "wait_before_index_creation" {
  depends_on      = [aws_opensearchserverless_collection.this]
  create_duration = "60s"
}

resource "opensearch_index" "this" {
  for_each                      = aws_opensearchserverless_collection.this
  name                          = lower("${var.index_name_prefix}-${each.value.tags["Department"]}")
  number_of_shards              = "2"
  number_of_replicas            = "0"
  index_knn                     = true
  index_knn_algo_param_ef_search = "512"
  mappings                      = <<-EOF
    {
      "properties": {
        "bedrock-knowledge-base-default-vector": {
          "type": "knn_vector",
          "dimension": 1536,
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
  depends_on      = [opensearch_index.this]
  create_duration = "30s"
}