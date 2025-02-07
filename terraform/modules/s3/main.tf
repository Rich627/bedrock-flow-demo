##############################
# S3 Module Configuration
##############################

#################
# S3 Buckets
# Creates encrypted S3 buckets for storing department documents
#################
resource "aws_s3_bucket" "this" {
  for_each      = { for bucket in var.buckets : bucket.name => bucket }
  bucket        = each.value.name
  force_destroy = true

  tags = {
    Department = each.value.department
  }
}

#################
# Public Access Block
# Ensures buckets are private and secure
#################
resource "aws_s3_bucket_public_access_block" "this" {
  for_each                = aws_s3_bucket.this
  bucket                  = each.value.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

#################
# KMS Encryption
# Creates KMS keys for bucket encryption
#################
resource "aws_kms_key" "this" {
  for_each                = aws_s3_bucket.this
  description             = "KMS key to encrypt S3 bucket ${each.key}"
  enable_key_rotation     = true
  deletion_window_in_days = 7
  
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "key-default-1"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:${data.aws_partition.this.partition}:iam::${data.aws_caller_identity.this.account_id}:root"
        },
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })
}

#################
# Bucket Encryption
# Configures S3 buckets to use KMS encryption
#################
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  for_each = aws_s3_bucket.this
  bucket   = each.value.id
  
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.this[each.key].arn
      sse_algorithm     = "aws:kms"
    }
  }
}

#################
# Bucket Versioning
# Enables versioning for data protection
#################
resource "aws_s3_bucket_versioning" "this" {
  for_each = aws_s3_bucket.this
  bucket   = each.value.id
  
  versioning_configuration {
    status = "Enabled"
  }
  depends_on = [aws_s3_bucket_server_side_encryption_configuration.this]
}