###############
### Frontend
###############

resource "aws_instance" "frontend" {
  count = 2

  ami           = var.ami_frontend
  instance_type = var.instance_type_frontend
  subnet_id     = var.subnet_frontend[count.index]

  vpc_security_group_ids = var.sg_frontend
  iam_instance_profile   = var.instance_profile_frontend

  tags = {
    Name = "${var.environment}-instance-frontend-${count.index + 1}"
  }
}

###############
### Backend
###############

resource "aws_instance" "backend" {
  count = 2

  ami           = var.ami_backend
  instance_type = var.instance_type_backend
  subnet_id     = var.subnet_backend[count.index]

  vpc_security_group_ids = var.sg_backend
  iam_instance_profile   = var.instance_profile_backend

  tags = {
    Name = "${var.environment}-instance-backend-${count.index + 1}"
  }
}