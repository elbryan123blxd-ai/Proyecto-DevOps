variable "rds_username" {
  type      = string
  sensitive = true
}

variable "rds_password" {
  type      = string
  sensitive = true
}

variable "rds_instance_class" {
  type    = string
  default = "db.t3.micro"
}
