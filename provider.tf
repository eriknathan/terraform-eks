terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.65.0"
    }
  }
  backend "s3" {
    bucket = "s3-erik-tf"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"
  }

}

provider "aws" {

}