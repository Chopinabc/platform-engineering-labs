output "instance_profile_name" {
    description = "Name of the iam profile instance"
    value = aws_iam_instance_profile.ec2_profile.name
  
}