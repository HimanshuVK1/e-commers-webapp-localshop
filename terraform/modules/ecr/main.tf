module "ecr" {
  source   = "git::https://github.com/terraform-aws-modules/terraform-aws-ecr.git?ref=b6ef04d088cf91d5ba9505132e9ff7c9f847ed5d"
  for_each = toset(var.services)

  repository_name = "${var.project_name}-${each.key}"

  repository_read_write_access_arns = []
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 10 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 10
        },
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2,
        description  = "Expire untagged images",
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

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}
