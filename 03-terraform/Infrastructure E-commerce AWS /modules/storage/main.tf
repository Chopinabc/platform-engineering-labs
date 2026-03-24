resource "aws_s3_bucket" "main" {
    bucket = "${var.environment}-ecommerce-storage-qwerasfd"
    tags = {
        Name = "${var.environment}-ecommerce-storage-qwerasfd"
    }
}

resource "aws_s3_bucket" "logs" {
    bucket = "${var.environment}-ecommerce-logs-qwerasfd"
    tags = {
      Name = "${var.environment}-ecommerce-logs-qwerasfd"
    }
  
}

resource "aws_s3_bucket_public_access_block" "main" {
    bucket = aws_s3_bucket.main.id

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
    bucket = aws_s3_bucket.main.id

    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  
}

resource "aws_s3_bucket_versioning" "main" {
    bucket = aws_s3_bucket.main.id

    versioning_configuration {
      status = "Enabled"
    }
  
}

resource "aws_s3_bucket_lifecycle_configuration" "main" {
    bucket = aws_s3_bucket.main.id

    rule {
      id = "delete-old-version"
      status = "Enabled"
      noncurrent_version_expiration {
        noncurrent_days = 90
      }
    }
  
}

resource "aws_s3_bucket_logging" "main" {
    bucket = aws_s3_bucket.main.id
    target_bucket = aws_s3_bucket.logs.id
    target_prefix = "s3-access-logs/"
  
}