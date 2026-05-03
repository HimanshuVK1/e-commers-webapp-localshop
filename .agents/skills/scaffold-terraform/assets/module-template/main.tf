terraform {
  # Strictly fixed version
  required_version = "1.11.2"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      # Strictly fixed version
      version = "6.43.0"
    }
  }
}

module "this" {
  source  = "terraform-aws-modules/<CHANGE_ME>/aws"
  # Mandatory fixed version (to be updated by agent using update script)
  version = "0.0.0"

  # Standard inputs
}
