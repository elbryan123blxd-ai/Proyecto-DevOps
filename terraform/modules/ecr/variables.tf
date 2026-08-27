variable "name_prefix" {
  description = "Prefijo de naming de los repositorios"
  type        = string
}

variable "repositories" {
  description = "Versiones de repositorios ECR a crear (ej: [\"api\", \"frontend\", \"worker\"])"
  type        = list(string)
  default     = ["api", "frontend", "worker"]
}

variable "image_count_to_keep" {
  description = "Cantidad de imágenes a conservar por repo"
  type        = number
  default     = 10
}

variable "tags" {
  description = "Tags extra"
  type        = map(string)
  default     = {}
}