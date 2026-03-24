###############
### Network Vars
###############
variable "vpc_cidr" {
    description = "description du cidr"
    type = string
  
}

variable "environment" {
    description = "description du l'env"
    type = string
  
}

variable "public_subnet_cidrs" {
    description = "public subnet"
    type = list(string)
}

variable "private_subnet_cidrs" {
    description = "private subnet"
    type = list(string)
}

###############
### Security Vars
###############


###############
### Database Vars
###############

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
    type = string
}

###############
### IAM Vars
###############


###############
### Compute Vars
###############

# Frontend
variable "instance_type_frontend" {
    type = string
}

# Backend
variable "instance_type_backend" {
    type = string
}
