variable "environment" {
  type = string
}

variable "cluster_prefix" {
  type = string
}

variable "rds_database_name" {
  type = string
}

variable "rds_username" {
  type      = string
  sensitive = true
}

variable "rds_password" {
  type      = string
  sensitive = true
}

variable "rds_instance_class" {
  type = string
}

variable "rds_security_group_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "skip_final_snapshot" {
  type    = bool
  default = true
}

variable "deletion_protection" {
  type    = bool
  default = false
}
