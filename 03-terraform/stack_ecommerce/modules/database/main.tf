resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = var.db_subnet_ids

  tags = {
    Name = "${var.environment}-db-subnet-group"
  }
}

resource "aws_kms_key" "db_key" {
  description             = "KMS key for RDS encryption"
  deletion_window_in_days = 10
  # enable_key_rotation     = true

  tags = {
    Name = "${var.environment}-rds-kms-key"
  }
}

resource "aws_kms_alias" "db_key_alias" {
  name          = "alias/${var.environment}-key-rds"
  target_key_id = aws_kms_key.db_key.key_id
}

resource "aws_db_instance" "db" {
  identifier        = "${var.environment}-db"
  engine            = var.engine_db
  engine_version    = var.engineversion_db
  instance_class    = var.instanceclass_db
  allocated_storage = var.storage_db
  storage_type      = var.storagetype_db

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.db_security_group_id]
  publicly_accessible    = false

  storage_encrypted = true
  kms_key_id        = aws_kms_key.db_key.arn 

  backup_retention_period = var.backup_retention_db
  backup_window           = "03:00-04:00"
  skip_final_snapshot     = true 

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  maintenance_window              = "mon:04:00-mon:05:00"

  tags = {
    Name = "${var.environment}-db"
  }
}