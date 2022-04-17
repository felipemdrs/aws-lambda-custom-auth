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