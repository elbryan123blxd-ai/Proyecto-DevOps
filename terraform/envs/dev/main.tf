terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.32"
    }
  }

  # Backend LOCAL ($0 costos). Cada ambiente tiene su propio state en su carpeta.
  # Para remote state compartido (S3 + DynamoDB), ver bootstrap/ y reactivar el backend "s3".
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      project     = var.project
      environment = var.environment
      managedby   = "terraform"
    }
  }
}

locals {
  name_prefix = "${var.project}-${var.environment}"
}

# --- Red ---
module "vpc" {
  source = "../../modules/vpc"

  name_prefix          = local.name_prefix
  cidr_block           = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  enable_nat           = var.enable_nat
  eks_cluster_name     = local.name_prefix

  tags = {
    environment = var.environment
  }
}

# --- Repositorios de imágenes ---
module "ecr" {
  source = "../../modules/ecr"

  name_prefix         = local.name_prefix
  repositories        = ["api", "frontend", "worker"]
  image_count_to_keep = var.ecr_image_count_to_keep
}

# Repos por entorno (promoción del mismo artefacto desde el CD, sin costo extra)
module "ecr_staging" {
  source = "../../modules/ecr"

  name_prefix         = "${var.project}-staging"
  repositories        = ["api", "frontend", "worker"]
  image_count_to_keep = var.ecr_image_count_to_keep
}

module "ecr_prod" {
  source = "../../modules/ecr"

  name_prefix         = "${var.project}-prod"
  repositories        = ["api", "frontend", "worker"]
  image_count_to_keep = var.ecr_image_count_to_keep
}

# --- Roles IAM (GitHub OIDC + gitops) ---
module "iam" {
  source = "../../modules/iam"

  name_prefix = local.name_prefix
  github_repo = var.github_repo
}

# --- Base de datos (Postgres, en prod apuntar RDS via DATABASE_URL) ---
module "rds" {
  source = "../../modules/rds"

  name_prefix         = local.name_prefix
  environment         = var.environment
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = length(module.vpc.private_subnet_ids) > 0 ? module.vpc.private_subnet_ids : module.vpc.public_subnet_ids
  allowed_cidr        = module.vpc.cidr_block
  db_password         = var.db_password
  instance_class      = var.db_instance_class
  multi_az            = var.db_multi_az
  deletion_protection = var.db_deletion_protection

  tags = {
    environment = var.environment
  }
}

# --- Cluster EKS (1 cluster por ambiente + namespace + nodegroup) ---
module "eks" {
  source = "../../modules/eks"

  cluster_name = local.name_prefix
  environment  = var.environment
  eks_version  = var.eks_version
  subnet_ids   = length(module.vpc.private_subnet_ids) > 0 ? module.vpc.private_subnet_ids : module.vpc.public_subnet_ids

  node_instance_types = var.node_instance_types
  node_min_size       = var.node_min_size
  node_desired_size   = var.node_desired_size
  node_max_size       = var.node_max_size
}

# --- Namespace del ambiente en el cluster ---
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.region]
  }
}

resource "kubernetes_namespace_v1" "env" {
  metadata {
    name = var.environment
    labels = {
      environment = var.environment
    }
  }

  depends_on = [module.eks]
}

# --- ArgoCD + Rollouts (GitOps) ---
module "argocd" {
  source = "../../modules/argocd"

  cluster_name           = module.eks.cluster_name
  cluster_endpoint       = module.eks.cluster_endpoint
  cluster_ca_certificate = module.eks.cluster_certificate_authority
  region                 = var.region
  argocd_chart_version   = var.argocd_chart_version
  install_rollouts       = var.install_rollouts
  admin_password         = var.argocd_admin_password
}

# --- Observabilidad (Fase 5): Prometheus + Grafana + Loki + ingress-nginx ---
module "observability" {
  source = "../../modules/observability"

  cluster_name           = module.eks.cluster_name
  cluster_endpoint       = module.eks.cluster_endpoint
  cluster_ca_certificate = module.eks.cluster_certificate_authority
  region                 = var.region
  grafana_admin_password = var.grafana_admin_password
}