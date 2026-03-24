###############
### EC2
###############

resource "aws_iam_role" "ec2_role" {
  name = "${var.environment}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "${var.environment}-ec2-role"
  }
}

resource "aws_iam_instance_profile" "ec2_profile" {
    
    name = "${var.environment}-ec2-profile"
    role = aws_iam_role.ec2_role.name

    tags = {
      Name = "${var.environment}-ec2-profile"
    }
}

###############
### S3
###############

resource "aws_iam_role_policy_attachment" "s3" {
    role = aws_iam_role.ec2_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  
}

###############
### SSM
###############

resource "aws_iam_role_policy_attachment" "ssm" {
    role = aws_iam_role.ec2_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  
}

###############
### CloudWatch
###############

resource "aws_iam_role_policy_attachment" "cloudWatch" {
    role = aws_iam_role.ec2_role.name
    policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  
}