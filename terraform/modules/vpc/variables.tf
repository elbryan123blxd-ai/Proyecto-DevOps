variable "name_prefix" {
  description = "Prefijo de naming de los recursos de red"
  type        = string
}

variable "cidr_block" {
  description = "CIDR de la VPC"
  type        = string
}

variable "availability_zones" {
  description = "AZs donde crear subnets"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDRs de las subnets públicas"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDRs de las subnets privadas"
  type        = list(string)
}

variable "enable_nat" {
  description = "Crear NAT Gateway para las subnets privadas"
  type        = bool
  default     = false
}

variable "eks_cluster_name" {
  description = "Nombre del cluster EKS (si se setea, agrega los tags kubernetes.io a las subnets)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags extra"
  type        = map(string)
  default     = {}
}