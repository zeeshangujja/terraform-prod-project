locals {
  name = lower("${var.project_name}-${var.environment}")
}

resource "aws_security_group" "rds" {
  name        = "${local.name}-rds-sg"
  description = "DB access only from ECS and private EC2"
  vpc_id      = var.vpc_id

  ingress {
    description     = "DB port from allowed security groups"
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = var.allowed_sg_ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${local.name}-rds-sg" }
}

resource "aws_db_subnet_group" "this" {
  name       = lower("${local.name}-db-subnet-group")
  subnet_ids = var.private_subnet_ids

  tags = { Name = "${local.name}-db-subnet-group" }
}

resource "aws_db_instance" "this" {
  identifier        = "${local.name}-db"
  engine            = var.db_engine
  engine_version    = var.db_engine_version
  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  port     = var.db_port

  # AWS generates the password and stores it in Secrets Manager
  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false  
  multi_az               = false

  skip_final_snapshot = true # practice setup; use false in real production

  tags = { Name = "${local.name}-db" }
}