resource "aws_security_group" "rds" {
  # checkov:skip=CKV2_AWS_5: Security group is attached to the RDS module instance.
  name_prefix = "${var.project_name}-${var.environment}-rds-sg"
  description = "Security group for RDS PostgreSQL instance"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow PostgreSQL traffic from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # VPC CIDR
  }
}

module "db" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-rds.git?ref=bc8c1e240a98fd54a12c61c70de91cbabec71863"

  identifier = "${var.project_name}-${var.environment}-db"

  engine               = "postgres"
  engine_version       = "16"
  family               = "postgres16" # DB parameter group
  major_engine_version = "16"         # DB option group
  instance_class       = "db.t4g.micro"

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"

  db_name  = "localshop"
  username = "dbadmin"
  port     = 5432

  manage_master_user_password = true

  # Cost Optimization: Single AZ, minimal backups
  multi_az                     = false
  backup_retention_period      = 1
  performance_insights_enabled = false

  db_subnet_group_name   = "${var.project_name}-${var.environment}-vpc"
  vpc_security_group_ids = [aws_security_group.rds.id]

  # Security
  storage_encrypted   = true
  skip_final_snapshot = true

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}
