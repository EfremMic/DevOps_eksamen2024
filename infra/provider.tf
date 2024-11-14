terraform {
  required_version = ">= 1.9.0"
  backend "s3" {
    bucket = "pgr301-2024-terraform-state"
    key    = "lambda-sqs/terraform.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  region = "eu-west-1"
}
