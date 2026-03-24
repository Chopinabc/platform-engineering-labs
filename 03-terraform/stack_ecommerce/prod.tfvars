###############
### Network
###############

vpc_cidr             = "10.0.0.0/16"
environment          = "prod"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]

###############
### Security
###############


###############
### Database
###############

db_name = "ecommercedb"
db_password = "CHANGEME"
db_username = "CHANGEME"
engine_db = "postgres"
engineversion_db = "17.6"
instanceclass_db = "db.t3.micro"
storage_db = 20
storagetype_db = "gp3"
backup_retention_db = 7

###############
### IAM
###############


###############
### Compute
###############
    #frontend
    instance_type_frontend = "t3.micro"

    #backend
    instance_type_backend = "t3.micro"

