terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  cloud {
    organization = "felipemdrs"

    workspaces {
      name = "aws-lambda-auth"
    }
  }
}

provider "aws" {
  version = "~> 4.8.0"
  region  = "us-east-1"
}
