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

variable "kube_prometheus_stack_version" {
  description = "Versión del chart kube-prometheus-stack (Prometheus + Grafana + AlertManager)"
  type        = string
  default     = "88.6.1"
}

variable "loki_version" {
  description = "Versión del chart loki (Grafana Loki, modo SingleBinary)"
  type        = string
  default     = "7.3.0"
}

variable "promtail_version" {
  description = "Versión del chart promtail (agente de logs hacia Loki)"
  type        = string
  default     = "6.17.1"
}

variable "ingress_nginx_version" {
  description = "Versión del chart ingress-nginx (controlador de Ingress, último release estable 4.15.x)"
  type        = string
  default     = "4.15.1"
}

variable "grafana_admin_password" {
  description = "Password admin de Grafana. Vacío = default del chart (prom-operator)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "tags" {
  description = "Tags extra"
  type        = map(string)
  default     = {}
}