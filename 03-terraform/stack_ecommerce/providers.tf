terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket         = "prod-terraform-state-qwerasfd"
    key            = "stack-ecommerce/prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "prod-terraform-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}