terraform {
  required_version = "1.15.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.43.0"
    }
  }
}

module "ecr" {
  source   = "git::https://github.com/terraform-aws-modules/terraform-aws-ecr.git?ref=b6ef04d088cf91d5ba9505132e9ff7c9f847ed5d"
  for_each = toset(var.services)

  repository_name = "${var.project_name}-${each.key}"

  repository_image_tag_mutability = var.image_tag_mutability
  repository_image_scan_on_push   = var.scan_on_push

  # Lifecycle Policy (Cost Optimized)
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 10 tagged images",
        selection = {
          tagStatus   = "any", # Using 'any' to ensure we keep 10 images regardless of prefix
          countType   = "imageCountMoreThan",
          countNumber = 10
        },
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2,
        description  = "Expire untagged images after 7 days",
        selection = {
          tagStatus   = "untagged",
          countType   = "sinceImagePushed",
          countUnit   = "days",
          countNumber = 7
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = merge(
    {
      Environment = var.environment
      Project     = var.project_name
      Module      = "ecr"
    },
    var.tags
  )
}
