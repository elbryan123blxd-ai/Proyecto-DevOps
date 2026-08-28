locals {
  tags = merge(var.tags, { module = "rds" })
}

resource "aws_db_subnet_group" "this" {
  name        = "${var.name_prefix}-subnet-group"
  subnet_ids  = var.subnet_ids
  description = "Subnet group para ${var.name_prefix} RDS"

  tags = merge(local.tags, { Name = "${var.name_prefix}-subnet-group" })
}

resource "aws_security_group" "db" {
  name        = "${var.name_prefix}-rds-sg"
  description = "Acceso a la BD Postgres desde la VPC"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { Name = "${var.name_prefix}-rds-sg" })
}

resource "aws_db_instance" "this" {
  identifier                   = "${var.name_prefix}-postgres"
  engine                       = "postgres"
  engine_version               = var.engine_version
  instance_class               = var.instance_class
  allocated_storage            = var.storage_size_gb
  storage_encrypted            = true
  multi_az                     = var.multi_az
  db_name                      = var.db_name
  username                     = var.db_user
  password                     = var.db_password
  db_subnet_group_name         = aws_db_subnet_group.this.name
  vpc_security_group_ids       = [aws_security_group.db.id]
  skip_final_snapshot          = true
  deletion_protection          = var.deletion_protection
  apply_immediately            = true
  performance_insights_enabled = false

  tags = merge(local.tags, {
    Name        = "${var.name_prefix}-postgres"
    environment = var.environment
  })

  # La password master se gestiona fuera de Terraform (Secrets Manager / manual).
  # Evita rotaciones accidentales o diffs por placeholder en el state.
  lifecycle {
    ignore_changes = [password]
  }
}