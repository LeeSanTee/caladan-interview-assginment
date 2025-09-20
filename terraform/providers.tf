terraform {
  required_providers {
    aws = {
      version = "~> 6.13.0"
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
  shared_credentials_files = ["~/.aws/credentials"]
}