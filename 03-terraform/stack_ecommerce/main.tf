###############
### State
###############
module "state_backend" {
  source      = "./state_backend"
  environment = var.environment
}

###############
### AMI
###############
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}


###############
### Network
###############
module "network" {
    source = "./modules/network"

    vpc_cidr = var.vpc_cidr
    environment = var.environment
    public_subnet_cidrs = var.public_subnet_cidrs
    private_subnet_cidrs = var.private_subnet_cidrs
    
}

###############
### Security
###############
module "security" {
    source = "./modules/security"

    vpc_id = module.network.vpc_id
    environment = var.environment
    
}

###############
### Database
###############

module "database" {
    source = "./modules/database"

    environment = var.environment
    db_subnet_ids = module.network.private_subnet_ids
    db_security_group_id = module.security.database_sg_id
    db_name = var.db_name
    db_password = var.db_password
    db_username = var.db_username
    engine_db = var.engine_db
    engineversion_db = var.engineversion_db
    instanceclass_db = var.instanceclass_db
    storage_db = var.storage_db
    storagetype_db = var.storagetype_db
    backup_retention_db = var.backup_retention_db

}

###############
### Storage
###############

module "storage" {
    source = "./modules/storage"

    environment = var.environment

}

###############
### IAM
###############
module "iam" {
    source = "./modules/iam"

    environment = var.environment
    

}

###############
### Compute
###############
module "compute" {
    source = "./modules/compute"

    environment = var.environment

    ami_frontend = data.aws_ami.amazon_linux_2.id
    instance_type_frontend = var.instance_type_frontend
    subnet_frontend = module.network.public_subnet_ids
    sg_frontend = [module.security.frontend_sg_id]
    instance_profile_frontend = module.iam.instance_profile_name

    ami_backend = data.aws_ami.amazon_linux_2.id
    instance_type_backend = var.instance_type_backend
    subnet_backend = module.network.private_subnet_ids
    sg_backend = [module.security.backend_sg_id]
    instance_profile_backend = module.iam.instance_profile_name


}

###############
### Endpoints
###############

module "endpoints" {
  source = "./modules/endpoints"

  vpc_id               = module.network.vpc_id
  private_subnet_cidrs = module.network.private_subnet_cidrs
  private_subnet_ids   = module.network.private_subnet_ids
  environment          = var.environment
}