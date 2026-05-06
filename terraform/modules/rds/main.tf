resource "aws_security_group" "rds" {
  name_prefix = "${var.project_name}-${var.environment}-rds-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # VPC CIDR
  }
}

module "db" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-rds.git?ref=a76a3cd92220b91eaa467a5328db6f2c21e1fdee"

  identifier = "${var.project_name}-${var.environment}-db"

  engine               = "postgres"
  engine_version       = "16"
  family               = "postgres16" # DB parameter group
  major_engine_version = "16"         # DB option group
  instance_class       = "db.t4g.micro"

  allocated_storage     = 20
  max_allocated_storage = 100

  db_name  = "localshop"
  username = "dbadmin"
  port     = 5432

  manage_master_user_password = true

  # Cost Optimization: Single AZ
  multi_az = false

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
