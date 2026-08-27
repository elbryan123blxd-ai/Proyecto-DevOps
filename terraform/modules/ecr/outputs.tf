output "repository_urls" {
  description = "Mapa repo -> URL completa para push/pull"
  value = {
    for k, repo in aws_ecr_repository.this : k => repo.repository_url
  }
}

output "repository_arns" {
  value = {
    for k, repo in aws_ecr_repository.this : k => repo.arn
  }
}