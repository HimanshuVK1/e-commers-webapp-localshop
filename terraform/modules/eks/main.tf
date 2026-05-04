module "eks" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-eks.git?ref=bef29c4d9523523e57fe898643fde2895106b339"

  name               = "${var.project_name}-${var.environment}-cluster"
  kubernetes_version = "1.31"

  vpc_id                   = var.vpc_id
  subnet_ids               = var.private_subnets
  control_plane_subnet_ids = var.private_subnets

  # Enable OIDC provider for IRSA
  enable_irsa = true

  # Cost Optimized Spot instances
  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.medium"]
      capacity_type  = "SPOT"
      min_size       = 1
      max_size       = 3
      desired_size   = 2
    }
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}
