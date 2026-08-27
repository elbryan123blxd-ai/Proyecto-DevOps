variable "project" {
  description = "Nombre del proyecto (prefijo)"
  type        = string
  default     = "cloudops"
}

variable "environment" {
  description = "Entorno: dev | staging | prod"
  type        = string
}

variable "region" {
  description = "Región AWS"
  type        = string
  default     = "us-east-1"
}

# --- VPC ---
variable "vpc_cidr" {
  type    = string
  default = "10.10.0.0/16"
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.10.1.0/24", "10.10.2.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.10.101.0/24", "10.10.102.0/24"]
}

variable "enable_nat" {
  description = "NAT Gateway para subnets privadas (~$32/mes; dejar false si se busca $0)"
  type        = bool
  default     = false
}

# --- ECR ---
variable "ecr_image_count_to_keep" {
  type    = number
  default = 10
}

# --- IAM / GitOps ---
variable "github_repo" {
  description = "Repo de GitHub (owner/repo) que asume el role vía OIDC"
  type        = string
  default     = "elbryan123blxd-ai/Proyecto-DevOps"
}

# --- RDS ---
variable "db_instance_class" {
  type    = string
  default = "db.t4g.micro"
}

variable "db_multi_az" {
  type    = bool
  default = false
}

variable "db_deletion_protection" {
  type    = bool
  default = false
}

variable "db_password" {
  description = "Password master de la BD"
  type        = string
  sensitive   = true
}

# --- EKS ---
variable "eks_version" {
  type    = string
  default = "1.31"
}

variable "node_instance_types" {
  type    = list(string)
  default = ["t3.medium"]
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

# --- ArgoCD ---
variable "argocd_chart_version" {
  type    = string
  default = "7.8.4"
}

variable "install_rollouts" {
  type    = bool
  default = true
}

variable "argocd_admin_password" {
  description = "Password admin de ArgoCD (bcrypt). Vacío = default del chart"
  type        = string
  sensitive   = true
  default     = ""
}