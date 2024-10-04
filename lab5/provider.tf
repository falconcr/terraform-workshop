terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "terraformworkshop"
    key            = "terraform.tfstate"
    region         = "us-east-1"
  }

  required_version = ">= 1.2.0"
}


provider "aws" {
  region = var.aws_region  # Región que se utilizará para crear recursos en AWS.
}

