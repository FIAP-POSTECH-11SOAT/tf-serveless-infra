terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "2.7.1"
    }
  }

  backend "s3" {
    bucket  = "rmsterraformstatefiap"
    key     = "infra/prod/serverless/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-1"
}
