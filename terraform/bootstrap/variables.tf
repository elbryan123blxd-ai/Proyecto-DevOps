variable "region" {
  description = "Región AWS"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Nombre del proyecto (prefijo de naming)"
  type        = string
  default     = "cloudops"
}

variable "state_bucket_name" {
  description = "Nombre del bucket S3 de remote state (único a nivel global)"
  type        = string
}

variable "lock_table_name" {
  description = "Nombre de la tabla DynamoDB de lock"
  type        = string
  default     = "terraform-state-lock"
}