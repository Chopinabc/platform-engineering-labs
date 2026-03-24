output "db_endpoint" {
    description = "RDS endpoint"
    sensitive = true
    value = aws_db_instance.db.endpoint
}

output "db_username" {
    description = "Database username"
    sensitive = true
    value = aws_db_instance.db.username
}

output "db_name" {
    description = "Database name"
    value = aws_db_instance.db.db_name
}