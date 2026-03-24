variable "environment" {
    description = "description de l'env"
    type = string
  
}

variable "db_subnet_ids" {
    type = list(string)
  
}

variable "db_security_group_id" {
    description = "Security Group ID for RDS"
    type = string
}

variable "db_name" {
    type = string
}

variable "db_username" {
    type = string
}

variable "db_password" {
    type = string
    sensitive = true
  
}

variable "engine_db" {
    type = string
}

variable "engineversion_db" {
    type = string
}

variable "instanceclass_db" {
    type = string
}

variable "storage_db" {
    type = number
}

variable "storagetype_db" {
    type = string
}

variable "backup_retention_db" {
    type = number
}