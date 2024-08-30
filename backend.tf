terraform {
  backend "s3" {
    bucket = "s3-erik-tf"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"
  }
}