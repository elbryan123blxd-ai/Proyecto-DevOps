output "rds_endpoint" {
  value = aws_db_instance.main.endpoint
}

output "rds_id" {
  value = aws_db_instance.main.id
}
