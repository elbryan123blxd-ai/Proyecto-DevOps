variable "cluster_name" {
  description = "Nombre del cluster EKS"
  type        = string
}

variable "environment" {
  description = "Entorno (dev/staging/prod)"
  type        = string
}

variable "eks_version" {
  description = "Versión de Kubernetes soportada por EKS"
  type        = string
  default     = "1.31"
}

variable "subnet_ids" {
  description = "Subnets del cluster (públicas o privadas)"
  type        = list(string)
}

variable "node_instance_types" {
  description = "Tipos de instancia del nodegroup"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_min_size" {
  type    = number
  default = 1
}

variable "node_desired_size" {
  type    = number
  default = 1
}

variable "node_max_size" {
  type    = number
  default = 3
}

variable "tags" {
  description = "Tags extra"
  type        = map(string)
  default     = {}
}