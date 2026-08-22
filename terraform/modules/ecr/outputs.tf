output "frontend_repo_url" {
  description = "URL del repositorio ECR del frontend"
  value       = aws_ecr_repository.frontend.repository_url
}

output "api_repo_url" {
  description = "URL del repositorio ECR de la API"
  value       = aws_ecr_repository.api.repository_url
}

output "worker_repo_url" {
  description = "URL del repositorio ECR del worker"
  value       = aws_ecr_repository.worker.repository_url
}