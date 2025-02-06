resource "aws_iam_role" "bedrock_kb" {
  for_each = { for dept in var.departments : dept.name => dept }
  
  name = "AmazonBedrockExecutionRoleForKnowledgeBase_${each.value.name}"
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
            "aws:SourceArn" = "arn:${local.partition}:bedrock:${local.region}:${local.account_id}:knowledge-base/*"
          }
        }
      }
    ]
  })

  tags = {
    Department = each.value.name
  }
}

resource "aws_iam_role_policy" "bedrock_kb_s3" {
  for_each = { for dept in var.departments : dept.name => dept }
  
  name = "AmazonBedrockS3PolicyForKnowledgeBase_${each.value.name}"
  role = aws_iam_role.bedrock_kb[each.key].name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "S3ListGetPutObjectStatement"
        Action   = ["s3:List*", "s3:Get*", "s3:PutObject"]
        Effect   = "Allow"
        Resource = [each.value.s3_arn, "${each.value.s3_arn}/*"]
        Condition = {
          StringEquals = {
            "aws:PrincipalAccount" = local.account_id
          }
        }
      },
      {
        Sid      = "KMSPermissions"
        Action   = ["kms:*"]
        Effect   = "Allow"
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_iam_role_policy" "bedrock_kb_model" {
  for_each = aws_iam_role.bedrock_kb
  
  name = "AmazonBedrockFoundationModelPolicyForKnowledgeBase_${each.key}"
  role = each.value.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "bedrock:InvokeModel"
        Effect   = "Allow"
        Resource = var.kb_model_arn
      }
    ]
  })
}