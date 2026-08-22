module "vpc" {
  source = "../../modules/vpc"

  environment = "prod"
  vpc_cidr    = "10.2.0.0/16"
  vpc_name    = "cloudops-gym-prod"
}

module "ecr" {
  source = "../../modules/ecr"

  environment = "prod"
}

module "iam" {
  source = "../../modules/iam"

  environment      = "prod"
  eks_cluster_name = "cloudops-gym-prod-cluster"
}

module "rds" {
  source = "../../modules/rds"

  environment           = "prod"
  cluster_prefix        = "cloudops-gym-prod"
  rds_database_name     = "gymdb"
  rds_username          = var.rds_username
  rds_password          = var.rds_password
  rds_instance_class    = "db.t3.medium"
  rds_security_group_id = module.vpc.default_security_group_id
  private_subnet_ids    = module.vpc.private_subnets
}

module "eks" {
  source = "../../modules/eks"

  environment        = "prod"
  eks_cluster_name   = "cloudops-gym-prod-cluster"
  private_subnet_ids = module.vpc.private_subnets
  eks_node_role_arn  = module.iam.eks_node_role_arn
}

module "argocd" {
  source = "../../modules/argocd"

  environment          = "prod"
  eks_cluster_name     = module.eks.cluster_name
  eks_cluster_endpoint = module.eks.cluster_endpoint
}
