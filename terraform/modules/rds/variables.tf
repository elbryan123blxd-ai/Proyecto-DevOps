variable "name_prefix" {
  description = "Prefijo de naming de la instancia RDS"
  type        = string
}

variable "environment" {
  description = "Entorno (dev/staging/prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC donde vive la BD"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets de la BD (privadas preferidas)"
  type        = list(string)
}

variable "allowed_cidr" {
  description = "CIDR que puede conectarse a la BD (generalmente el CIDR de la VPC)"
  type        = string
}

variable "db_name" {
  description = "Nombre de la base de datos"
  type        = string
  default     = "appdb"
}

variable "db_user" {
  description = "Usuario master de la BD"
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "Password master (guardar en AWS Secrets Manager en prod)"
  type        = string
  sensitive   = true
}

variable "instance_class" {
  description = "Clase de instancia RDS"
  type        = string
  default     = "db.t4g.micro"
}

variable "engine_version" {
  description = "Versión de Postgres"
  type        = string
  default     = "16.4"
}

variable "multi_az" {
  description = "Multi-AZ (alta disponibilidad, más costoso)"
  type        = bool
  default     = false
}

variable "storage_size_gb" {
  description = "Almacenamiento en GB"
  type        = number
  default     = 20
}

variable "deletion_protection" {
  description = "Protección contra borrado accidental (recomendado en prod)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags extra"
  type        = map(string)
  default     = {}
}