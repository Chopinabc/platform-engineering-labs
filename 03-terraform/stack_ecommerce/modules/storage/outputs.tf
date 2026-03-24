output "bucket_name" {
    description = "Bucket main name"
    value = aws_s3_bucket.main.bucket
  
}

output "bucket_arn" {
    description = "Bucket main arn"
    value = aws_s3_bucket.main.arn
  
}