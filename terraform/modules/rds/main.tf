resource "aws_db_subnet_group" "main" {
  name       = "${var.cluster_prefix}-subnet-group"
  subnet_ids = var.private_subnet_ids
  tags = {
    Name        = "${var.cluster_prefix}-subnet-group"
    Environment = var.environment
  }
}

resource "aws_db_instance" "main" {
  identifier             = "${var.cluster_prefix}-db"
  engine                 = "postgres"
  engine_version         = "16.6"
  instance_class         = var.rds_instance_class
  allocated_storage      = 20
  storage_type           = "gp3"
  db_name                = var.rds_database_name
  username               = var.rds_username
  password               = var.rds_password
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.rds_security_group_id]
  publicly_accessible    = false
  skip_final_snapshot    = var.skip_final_snapshot
  deletion_protection    = var.deletion_protection
  backup_retention_period = 7
  tags = {
    Name        = "${var.cluster_prefix}-db"
    Environment = var.environment
  }
}
