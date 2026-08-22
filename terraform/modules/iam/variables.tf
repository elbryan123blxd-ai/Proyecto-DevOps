variable "environment" {
  description = "Entorno (dev, staging, prod)"
  type        = string
}

variable "eks_cluster_name" {
  description = "Nombre del cluster EKS"
  type        = string
  default     = "cloudops-gym-cluster"
}