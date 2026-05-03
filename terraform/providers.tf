terraform {
  required_version = "1.15.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.43.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "localshop"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
