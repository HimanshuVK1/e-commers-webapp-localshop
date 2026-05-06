terraform {
  required_version = "1.15.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.43.0"
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

module "vpc" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git?ref=7c1f791efd61f326ed6102d564d1a65d1eceedf0"

  name = "localshop-${var.environment}-vpc"
  cidr = "10.0.0.0/16"

  azs = slice(data.aws_availability_zones.available.names, 0, 3)

  # 3-Tier Architecture
  public_subnets   = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets  = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  database_subnets = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"] # Isolated

  # NAT Gateway for Private Subnet Internet Access
  enable_nat_gateway     = true
  single_nat_gateway     = true # Cost Optimized: Use a single NAT Gateway for the prototype
  one_nat_gateway_per_az = false

  # DNS Support for Interface Endpoints
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Database Subnet Security (Isolated)
  create_database_subnet_group       = true
  create_database_subnet_route_table = true

  # Security Hardening
  map_public_ip_on_launch = false

  # VPC Flow Logs (S3)
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = false
  create_flow_log_cloudwatch_iam_role  = false
  flow_log_destination_type            = "s3"
  flow_log_destination_arn             = aws_s3_bucket.vpc_flow_logs.arn
  flow_log_max_aggregation_interval    = 60

  # Default Security Group - Strip all rules
  manage_default_security_group  = true
  default_security_group_ingress = []
  default_security_group_egress  = []

  # EKS Tagging Requirements
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}

resource "aws_s3_bucket" "vpc_flow_logs" {
  bucket        = "localshop-${var.environment}-vpc-flow-logs-${data.aws_caller_identity.current.account_id}"
  force_destroy = true

  tags = local.tags
}

resource "aws_s3_bucket_versioning" "vpc_flow_logs" {
  bucket = aws_s3_bucket.vpc_flow_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Added S3 Event Notifications
resource "aws_s3_bucket_notification" "vpc_flow_logs" {
  bucket      = aws_s3_bucket.vpc_flow_logs.id
  eventbridge = true
}

resource "aws_s3_bucket_lifecycle_configuration" "vpc_flow_logs" {
  bucket = aws_s3_bucket.vpc_flow_logs.id

  rule {
    id     = "flow-log-lifecycle"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    transition {
      days          = 90
      storage_class = "GLACIER_IR"
    }

    expiration {
      days = 365
    }
  }
}

resource "aws_s3_bucket_public_access_block" "vpc_flow_logs" {
  bucket = aws_s3_bucket.vpc_flow_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "vpc_flow_logs" {
  bucket = aws_s3_bucket.vpc_flow_logs.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_policy" "vpc_flow_logs" {
  bucket = aws_s3_bucket.vpc_flow_logs.id
  policy = data.aws_iam_policy_document.vpc_flow_logs_policy.json
}

data "aws_iam_policy_document" "vpc_flow_logs_policy" {
  statement {
    sid = "AWSLogDeliveryWrite"
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.vpc_flow_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  statement {
    sid = "AWSLogDeliveryAclCheck"
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.vpc_flow_logs.arn]
  }

  statement {
    sid    = "DenyNonSSLRequests"
    effect = "Deny"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.vpc_flow_logs.arn,
      "${aws_s3_bucket.vpc_flow_logs.arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

# Custom S3 Endpoint Policy
data "aws_iam_policy_document" "s3_endpoint_policy" {
  statement {
    sid     = "AllowVpcFlowLogs"
    effect  = "Allow"
    actions = ["s3:PutObject", "s3:GetBucketAcl"]
    resources = [
      aws_s3_bucket.vpc_flow_logs.arn,
      "${aws_s3_bucket.vpc_flow_logs.arn}/*"
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }

  statement {
    sid    = "AllowECRLayers"
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::prod-${data.aws_region.current.region}-starport-layer-bucket/*",
      "arn:aws:s3:::prod-us-east-1-starport-layer-bucket/*"
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

# Interface Endpoints Security Group
resource "aws_security_group" "vpc_endpoints" {
  name        = "localshop-${var.environment}-vpc-endpoints"
  description = "Security group for VPC Interface Endpoints"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  tags = local.tags
}

# 4. S3 Access Logging Configuration
resource "aws_s3_bucket_logging" "vpc_flow_logs" {
  bucket = aws_s3_bucket.vpc_flow_logs.id

  target_bucket = var.s3_access_log_bucket_id
  target_prefix = "vpc-flow-logs/"
}

# ECR API Endpoint
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [module.vpc.private_subnets[0]] # Cost Optimized: Deploy in 1 AZ
  security_group_ids  = [aws_security_group.vpc_endpoints.id]

  tags = merge(local.tags, { Name = "ecr-api-endpoint" })
}

# ECR DKR Endpoint
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [module.vpc.private_subnets[0]] # Cost Optimized: Deploy in 1 AZ
  security_group_ids  = [aws_security_group.vpc_endpoints.id]

  tags = merge(local.tags, { Name = "ecr-dkr-endpoint" })
}

# S3 Gateway Endpoint (Manual)
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = module.vpc.private_route_table_ids
  policy            = data.aws_iam_policy_document.s3_endpoint_policy.json

  tags = merge(local.tags, { Name = "s3-endpoint" })
}

# Secrets Manager Endpoint
resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [module.vpc.private_subnets[0]] # Cost Optimized: Deploy in 1 AZ
  security_group_ids  = [aws_security_group.vpc_endpoints.id]

  tags = merge(local.tags, { Name = "secretsmanager-endpoint" })
}
