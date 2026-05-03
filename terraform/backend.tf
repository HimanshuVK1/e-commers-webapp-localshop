terraform {
  backend "s3" {
    bucket       = "localshop-terraform-statefile"
    key          = "environments/dev/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true # Native S3 locking (Terraform 1.10+)
  }
}
