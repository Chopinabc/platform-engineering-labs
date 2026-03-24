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