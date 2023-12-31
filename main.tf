terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.29.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "2.4.0"
    }
  }

  backend "s3" {
    bucket         = "remote-state-tf-1523"
    key            = "project/transcriber/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "tf-locks-table"
    encrypt        = true
  }
}

data "aws_caller_identity" "me" {}
