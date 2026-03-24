variable "environment" {
    type = string
}

###############
### Frontend
###############

variable "ami_frontend" {
    type = string
}

variable "instance_type_frontend" {
    type = string
}

variable "subnet_frontend" {
    type = list(string)
}

variable "sg_frontend" {
    type = list(string)
}

variable "instance_profile_frontend" {
    type = string
}


###############
### Backend
###############

variable "ami_backend" {
    type = string
}

variable "instance_type_backend" {
    type = string
}

variable "subnet_backend" {
    type = list(string)
}

variable "sg_backend" {
    type = list(string)
}

variable "instance_profile_backend" {
    type = string
}