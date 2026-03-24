output "tfstate_bucket_name" {
  value = aws_s3_bucket.tfstate.id
}

output "tfstate_dynamodb_table" {
  value = aws_dynamodb_table.tfstate_lock.name
}