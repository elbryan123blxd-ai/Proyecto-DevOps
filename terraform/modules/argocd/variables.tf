variable "cluster_name" {
  description = "Nombre del cluster EKS (para generar el token vía aws eks get-token)"
  type        = string
}

variable "cluster_endpoint" {
  description = "Endpoint del cluster EKS"
  type        = string
}

variable "cluster_ca_certificate" {
  description = "CA base64 del cluster EKS"
  type        = string
}

variable "region" {
  description = "Región AWS"
  type        = string
  default     = "us-east-1"
}

variable "argocd_chart_version" {
  description = "Versión del chart argo-cd"
  type        = string
  default     = "7.8.4"
}

variable "install_rollouts" {
  description = "Instalar también ArgoCD Rollouts (canary)"
  type        = bool
  default     = true
}

variable "image_updater_enabled" {
  description = "Instalar ArgoCD Image Updater (detecta imágenes nuevas en ECR)"
  type        = bool
  default     = true
}

variable "image_updater_chart_version" {
  description = "Versión del chart argocd-image-updater (renombrado en v1.0.0)"
  type        = string
  default     = "1.2.4"
}

variable "admin_password" {
  description = "Password de admin de ArgoCD (chart lo encripta con bcrypt)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "tags" {
  description = "Tags extra"
  type        = map(string)
  default     = {}
}