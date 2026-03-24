resource "aws_security_group" "frontend" {
  name        = "${var.environment}-frontend-sg"
  description = "Security group for frontend servers"
  vpc_id      = var.vpc_id

  # HTTP
    ingress { 
        description = "HTTP from internet"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"] 
    }

    # HTTPS
    ingress {  
        description = "HTTPS from internet"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"  
        cidr_blocks = ["0.0.0.0/0"]  
    }

    # Egress : Tout autorisé
    egress {  
        description = "Allow all outbound"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"  
        cidr_blocks = ["0.0.0.0/0"]  
    }

    tags = {
        Name = "${var.environment}-frontend-sg"
    }
}


resource "aws_security_group" "backend" {
    name = "${var.environment}-backend-sg"
    description = "Security group for backend servers"
    vpc_id = var.vpc_id

    #API
    ingress {
        from_port   = 3000
        to_port     = 3000
        protocol    = "tcp"
        security_groups = [aws_security_group.frontend.id]
    }


    # Egress : Tout autorisé
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    tags = {
      Name = "${var.environment}-backend-sg"
    }
  
}

resource "aws_security_group" "database" {
    name = "${var.environment}-database-sg"
    description = "Security group for database servers"
    vpc_id = var.vpc_id

    #DP
    ingress {
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        security_groups = [aws_security_group.backend.id]
    }

    # Egress : Tout autorisé
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    tags = {
      Name = "${var.environment}-database-sg"
    }
  
}