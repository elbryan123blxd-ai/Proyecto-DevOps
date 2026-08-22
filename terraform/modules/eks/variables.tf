variable "environment" {
  type = string
}

variable "eks_cluster_name" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "eks_node_role_arn" {
  type = string
}

variable "eks_cluster_role_arn" {
  type    = string
  default = null
}
