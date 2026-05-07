terraform {
  required_version = "1.15.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.43.0"
    }
  }
}

resource "aws_security_group" "rds" {
  # checkov:skip=CKV_AWS_382: Egress allowed to all is acceptable for RDS prototype.
  # checkov:skip=CKV2_AWS_5: Security group is attached via Terraform module which Checkov might not detect.
  name        = "${var.project_name}-${var.environment}-rds-sg"
  description = "Security group for RDS PostgreSQL instance"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow PostgreSQL traffic from within VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-rds-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}

module "db" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-rds.git?ref=bc8c1e240a98fd54a12c61c70de91cbabec71863" # v7.2.0

  identifier = "${var.project_name}-${var.environment}-db"

  # Engine Config
  engine               = "postgres"
  engine_version       = "16"
  family               = "postgres16"
  major_engine_version = "16"
  instance_class       = "db.t4g.micro"

  # Master Password Management (AWS Secrets Manager)
  manage_master_user_password = true

  # Storage Config
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"

  # Database Config
  db_name  = "localshop"
  username = "dbadmin"
  port     = 5432

  # Connectivity
  db_subnet_group_name   = var.database_subnet_group_name
  vpc_security_group_ids = [aws_security_group.rds.id]

  # Cost Optimization (Prototype)
  multi_az                     = false
  backup_retention_period      = 1
  performance_insights_enabled = false
  skip_final_snapshot          = true

  # Tagging
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}
