terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
  backend "s3" {
    bucket         = "cloudops-gym-tfstate-bryan-2026"
    key            = "staging/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "cloudops-gym-tfstate-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags { tags = { Project = "cloudops-gym", Environment = "staging", Owner = "bryan" } }
}
