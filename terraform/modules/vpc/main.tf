terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
}

module "vpc" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git?ref=3ffbd46fb1c7733e1b34d8666893280454e27436"

  name = "${var.project_name}-${var.environment}-vpc"
  cidr = var.vpc_cidr

  azs              = local.azs
  public_subnets   = var.public_subnets
  private_subnets  = var.private_subnets
  database_subnets = var.database_subnets

  # Database Subnets (Isolated)
  create_database_subnet_group           = true
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = false

  # Networking
  enable_nat_gateway     = true
  single_nat_gateway     = true # Cost optimized for development
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  # VPC Flow Logs
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60

  # Tags for EKS Integration
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"                                      = "1"
    "kubernetes.io/cluster/${var.project_name}-${var.environment}-cluster" = "owned"
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# --- VPC Endpoints for Secure Private Communication ---

module "vpc_endpoints" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git//modules/vpc-endpoints?ref=3ffbd46fb1c7733e1b34d8666893280454e27436"

  vpc_id = module.vpc.vpc_id

  # Endpoints Security Group
  create_security_group      = true
  security_group_name_prefix = "${var.project_name}-${var.environment}-vpce-sg-"
  security_group_description = "Security group for VPC Endpoints"
  security_group_rules = {
    ingress_https = {
      description = "HTTPS from VPC"
      type        = "ingress"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [module.vpc.vpc_cidr_block]
    }
  }

  endpoints = {
    s3 = {
      service      = "s3"
      service_type = "Gateway"
      route_table_ids = flatten([
        module.vpc.private_route_table_ids,
        module.vpc.public_route_table_ids
      ])
      tags = { Name = "${var.project_name}-s3-endpoint" }
    },
    ecr_api = {
      service             = "ecr.api"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      tags                = { Name = "${var.project_name}-ecr-api-endpoint" }
    },
    ecr_dkr = {
      service             = "ecr.dkr"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      tags                = { Name = "${var.project_name}-ecr-dkr-endpoint" }
    },
    secretsmanager = {
      service             = "secretsmanager"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      tags                = { Name = "${var.project_name}-secretsmanager-endpoint" }
    }
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}
